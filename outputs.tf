output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.network_rg.name
}

output "hub_vnet_name" {
  description = "The name of the Hub VNet."
  value       = azurerm_virtual_network.hub_vnet.name
}

output "hub_firewall_private_ip" {
  description = "The private IP address of the Azure Firewall in the Hub VNet."
  value       = azurerm_firewall.hub_firewall.ip_configuration[0].private_ip_address
}

output "hub_bastion_public_ip" {
  description = "The public IP address of the Azure Bastion Host."
  value       = azurerm_public_ip.hub_bastion_pip.ip_address
}

output "dev_vnet_name" {
  description = "The name of the Dev Spoke VNet."
  value       = azurerm_virtual_network.dev_vnet.name
}

output "prod_vnet_name" {
  description = "The name of the Prod Spoke VNet."
  value       = azurerm_virtual_network.prod_vnet.name
}

output "private_dns_zone_id" {
  description = "The ID of the Private DNS Zone."
  value       = azurerm_private_dns_zone.internal_dns_zone.id
}

output "hub_vpn_gateway_public_ip" {
  description = "The public IP address of the Hub VPN Gateway."
  value       = azurerm_public_ip.hub_vpn_gateway_pip.ip_address
}