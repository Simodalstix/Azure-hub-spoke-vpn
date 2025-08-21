# Spoke VNet Module - Workload networks
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Spoke Virtual Network
resource "azurerm_virtual_network" "spoke" {
  name                = "${var.prefix}-${var.spoke_name}-vnet"
  address_space       = [var.spoke_address_space]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(var.tags, {
    Component = "Spoke"
    Workload  = var.spoke_name
  })
}

# Default Subnet
resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.default_subnet_cidr]

  private_endpoint_network_policies_enabled = false
}

# Application Subnet (optional)
resource "azurerm_subnet" "application" {
  count = var.create_app_subnet ? 1 : 0

  name                 = "application"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.app_subnet_cidr]

  private_endpoint_network_policies_enabled = false
}

# Data Subnet (optional)
resource "azurerm_subnet" "data" {
  count = var.create_data_subnet ? 1 : 0

  name                 = "data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.data_subnet_cidr]

  private_endpoint_network_policies_enabled = false
}

# VNet Peering to Hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "${var.prefix}-${var.spoke_name}-to-hub"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = var.hub_vnet_id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  use_remote_gateways          = var.use_remote_gateways
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "${var.prefix}-hub-to-${var.spoke_name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = true
}