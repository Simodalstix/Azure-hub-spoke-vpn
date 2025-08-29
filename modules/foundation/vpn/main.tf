# VPN Gateway Module
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Public IP for VPN Gateway
resource "azurerm_public_ip" "vpn_gateway" {
  name                = "${var.prefix}-vpn-gateway-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(var.tags, {
    Component = "VPN"
    Service   = "Connectivity"
  })
}

# VPN Gateway
resource "azurerm_virtual_network_gateway" "main" {
  name                = "${var.prefix}-vpn-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name

  type       = "Vpn"
  vpn_type   = "RouteBased"
  sku        = var.gateway_sku
  generation = var.gateway_generation

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  tags = merge(var.tags, {
    Component = "VPN"
    Service   = "Connectivity"
  })
}

# Local Network Gateway (for S2S connections)
resource "azurerm_local_network_gateway" "main" {
  for_each = var.local_networks

  name                = "${var.prefix}-${each.key}-lng"
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = each.value.gateway_address
  address_space       = each.value.address_space

  tags = merge(var.tags, {
    Component = "VPN"
    Network   = each.key
  })
}

# VPN Connections
resource "azurerm_virtual_network_gateway_connection" "main" {
  for_each = var.local_networks

  name                       = "${var.prefix}-${each.key}-connection"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id   = azurerm_local_network_gateway.main[each.key].id
  shared_key                 = each.value.shared_key

  tags = merge(var.tags, {
    Component = "VPN"
    Network   = each.key
  })
}