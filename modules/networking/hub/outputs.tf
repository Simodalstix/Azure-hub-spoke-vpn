output "vnet_id" {
  description = "Hub VNet ID"
  value       = azurerm_virtual_network.hub.id
}

output "vnet_name" {
  description = "Hub VNet name"
  value       = azurerm_virtual_network.hub.name
}

output "gateway_subnet_id" {
  description = "Gateway subnet ID"
  value       = azurerm_subnet.gateway.id
}

output "firewall_subnet_id" {
  description = "Firewall subnet ID"
  value       = azurerm_subnet.firewall.id
}

output "bastion_subnet_id" {
  description = "Bastion subnet ID"
  value       = azurerm_subnet.bastion.id
}

output "shared_services_subnet_id" {
  description = "Shared services subnet ID"
  value       = azurerm_subnet.shared_services.id
}

output "management_subnet_id" {
  description = "Management subnet ID"
  value       = azurerm_subnet.management.id
}