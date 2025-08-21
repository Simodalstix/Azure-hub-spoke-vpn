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

variable "hub_address_space" {
  description = "Hub VNet address space"
  type        = string
}

variable "gateway_subnet_cidr" {
  description = "Gateway subnet CIDR"
  type        = string
}

variable "firewall_subnet_cidr" {
  description = "Firewall subnet CIDR"
  type        = string
}

variable "bastion_subnet_cidr" {
  description = "Bastion subnet CIDR"
  type        = string
}

variable "shared_services_subnet_cidr" {
  description = "Shared services subnet CIDR"
  type        = string
}

variable "management_subnet_cidr" {
  description = "Management subnet CIDR"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}