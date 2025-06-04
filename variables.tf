variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
  default     = "Australia Southeast"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "EnterpriseNetworkRG"
}

variable "prefix" {
  description = "A prefix for all resource names to ensure uniqueness."
  type        = string
  default     = "entnet"
}

variable "hub_vnet_cidr" {
  description = "CIDR block for the Hub VNet."
  type        = string
  default     = "10.0.0.0/16"
}

variable "dev_vnet_cidr" {
  description = "CIDR block for the Dev Spoke VNet."
  type        = string
  default     = "10.10.0.0/16"
}

variable "prod_vnet_cidr" {
  description = "CIDR block for the Prod Spoke VNet."
  type        = string
  default     = "10.20.0.0/16"
}

variable "private_dns_zone_name" {
  description = "The name for the private DNS zone (e.g., 'internal.corp')."
  type        = string
  default     = "internal.corp"
}

# SHARED KEY
variable "vpn_shared_key" {
  description = "The shared key (PSK) for the Site-to-Site VPN connection."
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Absolute path to your SSH public key on this machine"
  type        = string
  default     = "/home/simoda/.ssh/id_rsa.pub" # no function call here
}

variable "admin_username" {
  default = "azureuser"
}
