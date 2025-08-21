variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "nsg_name" {
  description = "NSG name suffix"
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

variable "subnet_ids" {
  description = "List of subnet IDs to associate with NSG"
  type        = list(string)
  default     = []
}

variable "security_rules" {
  description = "Map of security rules"
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = {}
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}