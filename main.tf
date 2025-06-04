# Configure the AzureRM Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "network_rg" {
  name     = var.resource_group_name
  location = var.location
}

# --- Hub VNet ---

resource "azurerm_virtual_network" "hub_vnet" {
  name                = "${var.prefix}-hub-vnet"
  address_space       = [var.hub_vnet_cidr]
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

  tags = {
    Environment = "Hub"
    Project     = "EnterpriseNetwork"
  }
}

# Hub Subnets
resource "azurerm_subnet" "hub_gateway_subnet" {
  name                 = "GatewaySubnet" # Required name for VPN Gateway
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [cidrsubnet(var.hub_vnet_cidr, 8, 0)] # /24 subnet (adjust prefix length as needed)
}

resource "azurerm_subnet" "hub_azure_firewall_subnet" {
  name                 = "AzureFirewallSubnet" # Required name for Azure Firewall
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [cidrsubnet(var.hub_vnet_cidr, 8, 1)] # /24 subnet (adjust prefix length as needed)
}

resource "azurerm_subnet" "hub_azure_bastion_subnet" {
  name                 = "AzureBastionSubnet" # Required name for Azure Bastion
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.3.0/26"] # Pick an unused /26 range within the /16 Hub VNet
}

resource "azurerm_subnet" "hub_shared_services_subnet" {
  name                 = "SharedServicesSubnet"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [cidrsubnet(var.hub_vnet_cidr, 8, 2)]
}

# Azure Firewall Public IP
resource "azurerm_public_ip" "azure_firewall_pip" {
  name                = "${var.prefix}-hub-fw-pip"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Environment = "Hub"
    Service     = "Firewall"
  }
}

# Azure Firewall Policy
resource "azurerm_firewall_policy" "hub_fw_policy" {
  name                = "${var.prefix}-hub-fw-policy"
  resource_group_name = azurerm_resource_group.network_rg.name
  location            = azurerm_resource_group.network_rg.location


  dns {
    proxy_enabled = true
    servers = [
      "8.8.8.8",
      "1.1.1.1"
    ]
  }

  tags = {
    Environment = "Hub"
    Service     = "FirewallPolicy"
  }
}

# Azure Firewall
resource "azurerm_firewall" "hub_firewall" {
  name                = "${var.prefix}-hub-firewall"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard" # Or "Premium" for advanced features

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub_azure_firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.azure_firewall_pip.id
  }

  firewall_policy_id = azurerm_firewall_policy.hub_fw_policy.id

  tags = {
    Environment = "Hub"
    Service     = "Firewall"
  }
}

# VPN Gateway Public IP
resource "azurerm_public_ip" "hub_vpn_gateway_pip" {
  name                = "${var.prefix}-hub-vpngw-pip"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  allocation_method   = "Static"   # Or Static, depending on requirements
  sku                 = "Standard" # Or Standard/VpnGw1/2/3/4/5 for higher throughput
  tags = {
    Environment = "Hub"
    Service     = "VPNGateway"
  }
}

# VPN Gateway
resource "azurerm_virtual_network_gateway" "hub_vpn_gateway" {
  name                = "${var.prefix}-hub-vpngw"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  type                = "Vpn"
  vpn_type            = "RouteBased" # Or PolicyBased
  active_active       = false
  enable_bgp          = false
  sku                 = "VpnGw1" # Adjust SKU based on throughput requirements
  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.hub_vpn_gateway_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub_gateway_subnet.id
  }

  tags = {
    Environment = "Hub"
    Service     = "VPNGateway"
  }
}

# Azure Bastion Public IP
resource "azurerm_public_ip" "hub_bastion_pip" {
  name                = "${var.prefix}-hub-bastion-pip"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Environment = "Hub"
    Service     = "Bastion"
  }
}

# Azure Bastion Host
resource "azurerm_bastion_host" "hub_bastion_host" {
  name                = "${var.prefix}-hub-bastion"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  sku                 = "Standard" # Or Standard

  ip_configuration {
    name                 = "IpConfig"
    subnet_id            = azurerm_subnet.hub_azure_bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.hub_bastion_pip.id
  }

  tags = {
    Environment = "Hub"
    Service     = "Bastion"
  }
}

# --- Spoke VNets ---

# Spoke 1: Dev VNet
resource "azurerm_virtual_network" "dev_vnet" {
  name                = "${var.prefix}-dev-vnet"
  address_space       = [var.dev_vnet_cidr]
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

  tags = {
    Environment = "Dev"
    Project     = "EnterpriseNetwork"
  }
}

resource "azurerm_subnet" "dev_default_subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.dev_vnet.name
  address_prefixes     = [cidrsubnet(var.dev_vnet_cidr, 8, 0)] # /24 subnet
}

# VNet Peering: Dev to Hub
resource "azurerm_virtual_network_peering" "dev_to_hub_peering" {
  name                         = "${var.prefix}-dev-to-hub-peering"
  resource_group_name          = azurerm_resource_group.network_rg.name
  virtual_network_name         = azurerm_virtual_network.dev_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = true # Allow spoke to use hub's gateway
}

# VNet Peering: Hub to Dev
resource "azurerm_virtual_network_peering" "hub_to_dev_peering" {
  name                         = "${var.prefix}-hub-to-dev-peering"
  resource_group_name          = azurerm_resource_group.network_rg.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.dev_vnet.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  use_remote_gateways          = false # Hub does not use spokes gateway
}

# Spoke 2: Prod VNet
resource "azurerm_virtual_network" "prod_vnet" {
  name                = "${var.prefix}-prod-vnet"
  address_space       = [var.prod_vnet_cidr]
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

  tags = {
    Environment = "Prod"
    Project     = "EnterpriseNetwork"
  }
}

resource "azurerm_subnet" "prod_default_subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.prod_vnet.name
  address_prefixes     = [cidrsubnet(var.prod_vnet_cidr, 8, 0)] # /24 subnet
}

# NSG for Prod Spoke Subnet 
resource "azurerm_network_security_group" "spoke_nsg_prod" {
  name                = "${var.prefix}-spoke-nsg-prod"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

  # Allow inbound SSH/RDP from Azure Bastion
  security_rule {
    name      = "AllowBastionSSH"
    priority  = 100
    direction = "Inbound"
    access    = "Allow"
    protocol  = "Tcp"
    # Source is the Bastion Subnet CIDR
    source_address_prefix      = azurerm_subnet.hub_azure_bastion_subnet.address_prefixes[0]
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "22" # For Linux VMs (SSH)
    description                = "Allow SSH from Azure Bastion"
  }

  # Allow ICMP (Ping) from AWS VPC CIDR
  security_rule {
    name                       = "AllowPingFromAWS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_address_prefix      = "172.31.0.0/16" # AWS VPC CIDR
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    description                = "Allow ICMP from AWS VPC for VPN testing"
  }

  tags = {
    Environment = "Prod"
    Service     = "NetworkSecurityGroup"
  }
}

# --- Associate Prod Spoke Subnet with the NSG ---
resource "azurerm_subnet_network_security_group_association" "prod_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.prod_default_subnet.id
  network_security_group_id = azurerm_network_security_group.spoke_nsg_prod.id
}

# VNet Peering: Prod to Hub
resource "azurerm_virtual_network_peering" "prod_to_hub_peering" {
  name                         = "${var.prefix}-prod-to-hub-peering"
  resource_group_name          = azurerm_resource_group.network_rg.name
  virtual_network_name         = azurerm_virtual_network.prod_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  use_remote_gateways          = true # ✅ spoke uses hub's VPN
  depends_on                   = [azurerm_virtual_network_peering.hub_to_prod_peering]

}


# VNet Peering: Hub to Prod
resource "azurerm_virtual_network_peering" "hub_to_prod_peering" {
  name                         = "${var.prefix}-hub-to-prod-peering"
  resource_group_name          = azurerm_resource_group.network_rg.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.prod_vnet.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = true # ✅ hub advertises its VPN
}


# --- Private DNS Zones ---

resource "azurerm_private_dns_zone" "internal_dns_zone" {
  name                = var.private_dns_zone_name
  resource_group_name = azurerm_resource_group.network_rg.name
  tags = {
    Environment = "Shared"
    Service     = "DNS"
  }
}

# Link Private DNS Zone to Hub VNet
resource "azurerm_private_dns_zone_virtual_network_link" "hub_dns_link" {
  name                  = "${var.prefix}-hub-dns-link"
  resource_group_name   = azurerm_resource_group.network_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.internal_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  registration_enabled  = false # Typically set to false in Hub, but can be true if VMs register here.
}

# Link Private DNS Zone to Dev VNet
resource "azurerm_private_dns_zone_virtual_network_link" "dev_dns_link" {
  name                  = "${var.prefix}-dev-dns-link"
  resource_group_name   = azurerm_resource_group.network_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.internal_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.dev_vnet.id
  registration_enabled  = true # Allow VMs in spoke to register
}

# Link Private DNS Zone to Prod VNet
resource "azurerm_private_dns_zone_virtual_network_link" "prod_dns_link" {
  name                  = "${var.prefix}-prod-dns-link"
  resource_group_name   = azurerm_resource_group.network_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.internal_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.prod_vnet.id
  registration_enabled  = true # Allow VMs in spoke to register
}

# --- Route Tables for Forced Tunneling (via Azure Firewall) ---
# This ensures all outbound internet bound traffic from spokes goes through the hub firewall.

resource "azurerm_route_table" "spoke_route_table" {
  name                = "${var.prefix}-spoke-rt"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  # disable_bgp_route_propagation = false # Temporarily commented out

  # route {                                   # Temporarily commented out
  #   name                   = "DefaultRouteToFirewall"
  #   address_prefix         = "0.0.0.0/0"
  #   next_hop_type          = "VirtualAppliance"
  #   next_hop_in_ip_address = azurerm_firewall.hub_firewall.ip_configuration[0].private_ip_address
  # }

  tags = {
    Environment = "Shared"
    Service     = "RouteTable"
  }
}

# Associate route table to spoke subnets
resource "azurerm_subnet_route_table_association" "dev_subnet_rt_association" {
  subnet_id      = azurerm_subnet.dev_default_subnet.id
  route_table_id = azurerm_route_table.spoke_route_table.id
}

resource "azurerm_subnet_route_table_association" "prod_subnet_rt_association" {
  subnet_id      = azurerm_subnet.prod_default_subnet.id
  route_table_id = azurerm_route_table.spoke_route_table.id
}


# --- Optional: Site-to-Site VPN Connection Placeholder ---
# You'd need to configure your on-premises device (pfSense/strongSwan)
# with the details from the Azure Local Network Gateway and VPN Gateway.


resource "azurerm_local_network_gateway" "onprem_lng" {
  name                = "${var.prefix}-onprem-lng"
  resource_group_name = azurerm_resource_group.network_rg.name
  location            = azurerm_resource_group.network_rg.location
  gateway_address     = "13.239.236.178"  # on-premises public IP (AWS EC2)
  address_space       = ["172.31.0.0/16"] # on-premises network CIDR (AWS VPC)

  tags = {
    Environment = "Hybrid"
    Service     = "LocalNetworkGateway"
  }
}

resource "azurerm_virtual_network_gateway_connection" "s2s_connection" {
  name                       = "${var.prefix}-s2s-connection"
  resource_group_name        = azurerm_resource_group.network_rg.name
  location                   = azurerm_resource_group.network_rg.location
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.hub_vpn_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem_lng.id
  shared_key                 = var.vpn_shared_key

  tags = {
    Environment = "Hybrid"
    Service     = "VPNGatewayConnection"
  }
}
