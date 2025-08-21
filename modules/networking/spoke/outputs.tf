output "vnet_id" {
  description = "Spoke VNet ID"
  value       = azurerm_virtual_network.spoke.id
}

output "vnet_name" {
  description = "Spoke VNet name"
  value       = azurerm_virtual_network.spoke.name
}

output "default_subnet_id" {
  description = "Default subnet ID"
  value       = azurerm_subnet.default.id
}

output "app_subnet_id" {
  description = "Application subnet ID"
  value       = var.create_app_subnet ? azurerm_subnet.application[0].id : null
}

output "data_subnet_id" {
  description = "Data subnet ID"
  value       = var.create_data_subnet ? azurerm_subnet.data[0].id : null
}