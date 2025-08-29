# Azure Firewall Module
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Public IP for Azure Firewall
resource "azurerm_public_ip" "firewall" {
  name                = "${var.prefix}-firewall-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(var.tags, {
    Component = "Firewall"
    Service   = "Security"
  })
}

# Azure Firewall
resource "azurerm_firewall" "main" {
  name                = "${var.prefix}-firewall"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  tags = merge(var.tags, {
    Component = "Firewall"
    Service   = "Security"
  })
}

# Network Rule Collection
resource "azurerm_firewall_network_rule_collection" "main" {
  name                = "${var.prefix}-network-rules"
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name                  = "AllowInternetAccess"
    source_addresses      = var.spoke_address_spaces
    destination_ports     = ["80", "443", "53"]
    destination_addresses = ["*"]
    protocols             = ["TCP", "UDP"]
  }

  rule {
    name                  = "AllowVPNTraffic"
    source_addresses      = var.spoke_address_spaces
    destination_addresses = var.onprem_address_spaces
    destination_ports     = ["*"]
    protocols             = ["Any"]
  }
}

# Application Rule Collection
resource "azurerm_firewall_application_rule_collection" "main" {
  name                = "${var.prefix}-app-rules"
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name             = "AllowAzureServices"
    source_addresses = var.spoke_address_spaces
    target_fqdns = [
      "*.azure.com",
      "*.microsoft.com",
      "*.windows.net",
      "*.ubuntu.com",
      "*.debian.org"
    ]
    protocol {
      port = "443"
      type = "Https"
    }
    protocol {
      port = "80"
      type = "Http"
    }
  }
}