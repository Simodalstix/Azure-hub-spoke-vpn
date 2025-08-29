# Azure Enterprise Landing Zone - Hub-Spoke Network Architecture

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Common tags for all resources
locals {
  common_tags = {
    Environment   = var.environment
    Project       = "AzureLandingZone"
    Owner         = var.owner
    CostCenter    = var.cost_center
    CreatedBy     = "Terraform"
    CreatedDate   = timestamp()
  }

  # Network configuration
  hub_subnets = {
    gateway_subnet         = cidrsubnet(var.hub_address_space, 8, 0)   # /24
    firewall_subnet        = cidrsubnet(var.hub_address_space, 8, 1)   # /24
    bastion_subnet         = cidrsubnet(var.hub_address_space, 8, 2)   # /24
    shared_services_subnet = cidrsubnet(var.hub_address_space, 8, 3)   # /24
    management_subnet      = cidrsubnet(var.hub_address_space, 8, 4)   # /24
  }

  spoke_configs = {
    dev = {
      address_space      = var.dev_address_space
      default_subnet     = cidrsubnet(var.dev_address_space, 8, 0)
      app_subnet         = cidrsubnet(var.dev_address_space, 8, 1)
      data_subnet        = cidrsubnet(var.dev_address_space, 8, 2)
      create_app_subnet  = true
      create_data_subnet = true
    }
    prod = {
      address_space      = var.prod_address_space
      default_subnet     = cidrsubnet(var.prod_address_space, 8, 0)
      app_subnet         = cidrsubnet(var.prod_address_space, 8, 1)
      data_subnet        = cidrsubnet(var.prod_address_space, 8, 2)
      create_app_subnet  = true
      create_data_subnet = true
    }
    shared = {
      address_space      = var.shared_address_space
      default_subnet     = cidrsubnet(var.shared_address_space, 8, 0)
      app_subnet         = ""
      data_subnet        = ""
      create_app_subnet  = false
      create_data_subnet = false
    }
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-${var.environment}-rg"
  location = var.location
  tags     = local.common_tags
}

# Hub Network
module "hub_network" {
  source = "./modules/networking/hub"

  prefix                        = var.prefix
  location                      = var.location
  resource_group_name           = azurerm_resource_group.main.name
  hub_address_space             = var.hub_address_space
  gateway_subnet_cidr           = local.hub_subnets.gateway_subnet
  firewall_subnet_cidr          = local.hub_subnets.firewall_subnet
  bastion_subnet_cidr           = local.hub_subnets.bastion_subnet
  shared_services_subnet_cidr   = local.hub_subnets.shared_services_subnet
  management_subnet_cidr        = local.hub_subnets.management_subnet
  tags                          = local.common_tags
}

# Spoke Networks
module "spoke_networks" {
  source = "./modules/networking/spoke"
  for_each = local.spoke_configs

  prefix                = var.prefix
  spoke_name            = each.key
  location              = var.location
  resource_group_name   = azurerm_resource_group.main.name
  spoke_address_space   = each.value.address_space
  default_subnet_cidr   = each.value.default_subnet
  create_app_subnet     = each.value.create_app_subnet
  app_subnet_cidr       = each.value.app_subnet
  create_data_subnet    = each.value.create_data_subnet
  data_subnet_cidr      = each.value.data_subnet
  hub_vnet_id           = module.hub_network.vnet_id
  hub_vnet_name         = module.hub_network.vnet_name
  use_remote_gateways   = each.key != "shared" # Shared services don't need VPN
  tags                  = merge(local.common_tags, { Workload = each.key })
}

# Azure Firewall
module "firewall" {
  source = "./modules/security/firewall"

  prefix                = var.prefix
  location              = var.location
  resource_group_name   = azurerm_resource_group.main.name
  firewall_subnet_id    = module.hub_network.firewall_subnet_id
  firewall_sku_tier     = var.firewall_sku_tier
  spoke_address_spaces  = [for k, v in local.spoke_configs : v.address_space]
  onprem_address_spaces = var.onprem_address_spaces
  tags                  = local.common_tags
}

# Network Security Groups
module "spoke_nsgs" {
  source = "./modules/security/nsg"
  for_each = local.spoke_configs

  prefix              = var.prefix
  nsg_name            = each.key
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_ids          = compact([
    module.spoke_networks[each.key].default_subnet_id,
    module.spoke_networks[each.key].app_subnet_id,
    module.spoke_networks[each.key].data_subnet_id
  ])
  security_rules      = var.nsg_rules[each.key]
  tags                = merge(local.common_tags, { Workload = each.key })
}

# Key Vault
module "key_vault" {
  source = "./modules/foundation/keyvault"

  prefix                        = var.prefix
  location                      = var.location
  resource_group_name           = azurerm_resource_group.main.name
  network_acls_default_action   = "Allow" # Change to "Deny" for production
  allowed_subnet_ids            = [module.hub_network.management_subnet_id]
  vpn_shared_key                = var.vpn_shared_key
  tags                          = local.common_tags
}

# Private DNS
module "private_dns" {
  source = "./modules/foundation/dns"

  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.main.name
  dns_zone_name       = var.private_dns_zone_name
  vnet_links = merge(
    {
      hub = {
        vnet_id              = module.hub_network.vnet_id
        registration_enabled = false
      }
    },
    {
      for k, v in module.spoke_networks : k => {
        vnet_id              = v.vnet_id
        registration_enabled = true
      }
    }
  )
  tags = local.common_tags
}

# VPN Gateway (keeping your existing working configuration)
module "vpn_gateway" {
  source = "./modules/foundation/vpn"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  gateway_subnet_id   = module.hub_network.gateway_subnet_id
  gateway_sku         = var.vpn_gateway_sku
  local_networks = {
    aws = {
      gateway_address = var.aws_gateway_address
      address_space   = var.aws_address_spaces
      shared_key      = var.vpn_shared_key
    }
  }
  tags = local.common_tags
}

# Route Tables for spoke networks
resource "azurerm_route_table" "spoke" {
  for_each = local.spoke_configs

  name                = "${var.prefix}-${each.key}-rt"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  route {
    name                   = "DefaultToFirewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = module.firewall.firewall_private_ip
  }

  tags = merge(local.common_tags, { Workload = each.key })
}

# Route Table Associations
resource "azurerm_subnet_route_table_association" "spoke_default" {
  for_each = local.spoke_configs

  subnet_id      = module.spoke_networks[each.key].default_subnet_id
  route_table_id = azurerm_route_table.spoke[each.key].id
}

resource "azurerm_subnet_route_table_association" "spoke_app" {
  for_each = { for k, v in local.spoke_configs : k => v if v.create_app_subnet }

  subnet_id      = module.spoke_networks[each.key].app_subnet_id
  route_table_id = azurerm_route_table.spoke[each.key].id
}

resource "azurerm_subnet_route_table_association" "spoke_data" {
  for_each = { for k, v in local.spoke_configs : k => v if v.create_data_subnet }

  subnet_id      = module.spoke_networks[each.key].data_subnet_id
  route_table_id = azurerm_route_table.spoke[each.key].id
}