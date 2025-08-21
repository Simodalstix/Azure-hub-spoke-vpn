variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "spoke_name" {
  description = "Name of the spoke (e.g., dev, prod, shared)"
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

variable "spoke_address_space" {
  description = "Spoke VNet address space"
  type        = string
}

variable "default_subnet_cidr" {
  description = "Default subnet CIDR"
  type        = string
}

variable "create_app_subnet" {
  description = "Create application subnet"
  type        = bool
  default     = false
}

variable "app_subnet_cidr" {
  description = "Application subnet CIDR"
  type        = string
  default     = ""
}

variable "create_data_subnet" {
  description = "Create data subnet"
  type        = bool
  default     = false
}

variable "data_subnet_cidr" {
  description = "Data subnet CIDR"
  type        = string
  default     = ""
}

variable "hub_vnet_id" {
  description = "Hub VNet ID for peering"
  type        = string
}

variable "hub_vnet_name" {
  description = "Hub VNet name for peering"
  type        = string
}

variable "use_remote_gateways" {
  description = "Use remote gateways for VPN connectivity"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}