output "vpn_gateway_id" {
  description = "VPN Gateway ID"
  value       = azurerm_virtual_network_gateway.main.id
}

output "vpn_gateway_public_ip" {
  description = "VPN Gateway public IP"
  value       = azurerm_public_ip.vpn_gateway.ip_address
}