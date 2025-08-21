variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "sku_name" {
  description = "Key Vault SKU"
  type        = string
  default     = "standard"
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention days"
  type        = number
  default     = 7
}

variable "network_acls_default_action" {
  description = "Default action for network ACLs"
  type        = string
  default     = "Deny"
}

variable "allowed_ip_ranges" {
  description = "Allowed IP ranges"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "Allowed subnet IDs"
  type        = list(string)
  default     = []
}

variable "vpn_shared_key" {
  description = "VPN shared key to store"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}