# Enterprise Landing Zone Variables

# Core Configuration
variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "entlz"
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Australia Southeast"
}

variable "owner" {
  description = "Resource owner"
  type        = string
  default     = "Platform Team"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "IT-Infrastructure"
}

# Network Configuration
variable "hub_address_space" {
  description = "Hub VNet address space"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dev_address_space" {
  description = "Dev spoke address space"
  type        = string
  default     = "10.10.0.0/16"
}

variable "prod_address_space" {
  description = "Prod spoke address space"
  type        = string
  default     = "10.20.0.0/16"
}

variable "shared_address_space" {
  description = "Shared services spoke address space"
  type        = string
  default     = "10.30.0.0/16"
}

# Security Configuration
variable "firewall_sku_tier" {
  description = "Azure Firewall SKU tier"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.firewall_sku_tier)
    error_message = "Firewall SKU tier must be Standard or Premium."
  }
}

variable "nsg_rules" {
  description = "NSG rules for each spoke"
  type = map(map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  })))
  default = {
    dev = {
      AllowSSH = {
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.2.0/24" # Bastion subnet
        destination_address_prefix = "*"
      }
      AllowHTTP = {
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "10.0.0.0/16" # Hub VNet
        destination_address_prefix = "*"
      }
    }
    prod = {
      AllowSSH = {
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.2.0/24" # Bastion subnet
        destination_address_prefix = "*"
      }
      AllowHTTPS = {
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "10.0.0.0/16" # Hub VNet
        destination_address_prefix = "*"
      }
      AllowVPNTraffic = {
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Icmp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "172.31.0.0/16" # AWS VPC
        destination_address_prefix = "*"
      }
    }
    shared = {
      AllowManagement = {
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.4.0/24" # Management subnet
        destination_address_prefix = "*"
      }
    }
  }
}

# VPN Configuration
variable "vpn_gateway_sku" {
  description = "VPN Gateway SKU"
  type        = string
  default     = "VpnGw1"
}

variable "aws_gateway_address" {
  description = "AWS VPN endpoint public IP"
  type        = string
  default     = "13.239.236.178"
}

variable "aws_address_spaces" {
  description = "AWS VPC address spaces"
  type        = list(string)
  default     = ["172.31.0.0/16"]
}

variable "onprem_address_spaces" {
  description = "On-premises address spaces"
  type        = list(string)
  default     = ["172.31.0.0/16"]
}

variable "vpn_shared_key" {
  description = "VPN shared key"
  type        = string
  sensitive   = true
}

# DNS Configuration
variable "private_dns_zone_name" {
  description = "Private DNS zone name"
  type        = string
  default     = "internal.corp"
}