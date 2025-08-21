# Network Security Group Module
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-${var.nsg_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(var.tags, {
    Component = "NSG"
    Service   = "Security"
  })
}

# Default security rules
resource "azurerm_network_security_rule" "deny_all_inbound" {
  name                        = "DenyAllInbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.main.name
}

# Custom security rules
resource "azurerm_network_security_rule" "custom" {
  for_each = var.security_rules

  name                         = each.key
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = each.value.source_port_range
  destination_port_range       = each.value.destination_port_range
  source_address_prefix        = each.value.source_address_prefix
  destination_address_prefix   = each.value.destination_address_prefix
  resource_group_name          = var.resource_group_name
  network_security_group_name  = azurerm_network_security_group.main.name
}

# Subnet associations
resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = toset(var.subnet_ids)

  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.main.id
}