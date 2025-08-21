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

variable "firewall_subnet_id" {
  description = "Firewall subnet ID"
  type        = string
}

variable "firewall_sku_name" {
  description = "Firewall SKU name"
  type        = string
  default     = "AZFW_VNet"
}

variable "firewall_sku_tier" {
  description = "Firewall SKU tier"
  type        = string
  default     = "Standard"
}

variable "spoke_address_spaces" {
  description = "List of spoke address spaces"
  type        = list(string)
}

variable "onprem_address_spaces" {
  description = "List of on-premises address spaces"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}