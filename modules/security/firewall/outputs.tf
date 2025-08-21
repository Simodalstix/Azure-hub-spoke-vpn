output "firewall_id" {
  description = "Azure Firewall ID"
  value       = azurerm_firewall.main.id
}

output "firewall_private_ip" {
  description = "Azure Firewall private IP"
  value       = azurerm_firewall.main.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  description = "Azure Firewall public IP"
  value       = azurerm_public_ip.firewall.ip_address
}