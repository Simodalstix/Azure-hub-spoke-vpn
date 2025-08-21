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

variable "gateway_subnet_id" {
  description = "Gateway subnet ID"
  type        = string
}

variable "gateway_sku" {
  description = "VPN Gateway SKU"
  type        = string
  default     = "VpnGw1"
}

variable "gateway_generation" {
  description = "VPN Gateway generation"
  type        = string
  default     = "Generation1"
}

variable "local_networks" {
  description = "Local networks for S2S connections"
  type = map(object({
    gateway_address = string
    address_space   = list(string)
    shared_key      = string
  }))
  default = {}
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}