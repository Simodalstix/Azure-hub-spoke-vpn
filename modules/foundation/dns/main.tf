# Private DNS Module
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "main" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name

  tags = merge(var.tags, {
    Component = "DNS"
    Service   = "Foundation"
  })
}

# VNet Links
resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  for_each = var.vnet_links

  name                  = "${var.prefix}-${each.key}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = each.value.registration_enabled

  tags = merge(var.tags, {
    Component = "DNS"
    VNet      = each.key
  })
}