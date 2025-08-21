variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "dns_zone_name" {
  description = "Private DNS zone name"
  type        = string
}

variable "vnet_links" {
  description = "VNet links for DNS zone"
  type = map(object({
    vnet_id              = string
    registration_enabled = bool
  }))
  default = {}
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}