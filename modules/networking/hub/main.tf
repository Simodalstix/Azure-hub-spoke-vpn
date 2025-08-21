# Hub VNet Module - Core networking infrastructure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Hub Virtual Network
resource "azurerm_virtual_network" "hub" {
  name                = "${var.prefix}-hub-vnet"
  address_space       = [var.hub_address_space]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(var.tags, {
    Component = "Hub"
    Tier      = "Network"
  })
}

# Gateway Subnet (required for VPN Gateway)
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.gateway_subnet_cidr]
}

# Azure Firewall Subnet
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.firewall_subnet_cidr]
}

# Azure Bastion Subnet
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.bastion_subnet_cidr]
}

# Shared Services Subnet
resource "azurerm_subnet" "shared_services" {
  name                 = "shared-services"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.shared_services_subnet_cidr]

  private_endpoint_network_policies_enabled = false
}

# Management Subnet
resource "azurerm_subnet" "management" {
  name                 = "management"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.management_subnet_cidr]
}