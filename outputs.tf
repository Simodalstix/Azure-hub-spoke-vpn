# Enterprise Landing Zone Outputs

# Resource Group
output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = azurerm_resource_group.main.id
}

# Hub Network
output "hub_vnet_id" {
  description = "Hub VNet ID"
  value       = module.hub_network.vnet_id
}

output "hub_vnet_name" {
  description = "Hub VNet name"
  value       = module.hub_network.vnet_name
}

# Spoke Networks
output "spoke_vnet_ids" {
  description = "Spoke VNet IDs"
  value       = { for k, v in module.spoke_networks : k => v.vnet_id }
}

output "spoke_vnet_names" {
  description = "Spoke VNet names"
  value       = { for k, v in module.spoke_networks : k => v.vnet_name }
}

# Security
output "firewall_private_ip" {
  description = "Azure Firewall private IP"
  value       = module.firewall.firewall_private_ip
}

output "firewall_public_ip" {
  description = "Azure Firewall public IP"
  value       = module.firewall.firewall_public_ip
}

output "nsg_ids" {
  description = "NSG IDs by spoke"
  value       = { for k, v in module.spoke_nsgs : k => v.nsg_id }
}

# Foundation Services
output "key_vault_name" {
  description = "Key Vault name"
  value       = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = module.key_vault.key_vault_uri
}

output "private_dns_zone_name" {
  description = "Private DNS zone name"
  value       = module.private_dns.dns_zone_name
}

# VPN
output "vpn_gateway_public_ip" {
  description = "VPN Gateway public IP"
  value       = module.vpn_gateway.vpn_gateway_public_ip
}

# Network Summary
output "network_summary" {
  description = "Network architecture summary"
  value = {
    hub_address_space = var.hub_address_space
    spoke_address_spaces = {
      dev    = var.dev_address_space
      prod   = var.prod_address_space
      shared = var.shared_address_space
    }
    firewall_ip    = module.firewall.firewall_private_ip
    vpn_gateway_ip = module.vpn_gateway.vpn_gateway_public_ip
  }
}