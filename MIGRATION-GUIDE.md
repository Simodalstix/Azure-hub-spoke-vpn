# Migration Guide: From Hub-Spoke to Enterprise Landing Zone

This guide helps you migrate from the original hub-spoke implementation to the enterprise-grade landing zone architecture.

## Overview

The enterprise landing zone provides:
- **Modular Architecture**: Reusable Terraform modules
- **Enhanced Security**: Comprehensive NSG rules, Key Vault integration
- **Better Governance**: Consistent tagging, RBAC-ready structure
- **Scalability**: Easy addition of new spokes and services
- **Compliance**: Enterprise security standards

## Pre-Migration Checklist

### 1. Backup Current State
```bash
# Backup Terraform state
terraform state pull > backup-$(date +%Y%m%d).tfstate

# Export current configuration
terraform show > current-config-$(date +%Y%m%d).txt

# Document current resources
az resource list --resource-group your-rg-name --output table > resources-$(date +%Y%m%d).txt
```

### 2. Assess Current Resources
- [ ] Resource Group and naming convention
- [ ] VNet address spaces and subnets
- [ ] VPN Gateway configuration (keep working settings!)
- [ ] NSG rules and associations
- [ ] Route tables and routes
- [ ] DNS configuration
- [ ] Any custom resources or configurations

### 3. Plan Migration Strategy

**Option A: Clean Deployment (Recommended)**
- Deploy enterprise landing zone to new resource group
- Migrate workloads gradually
- Decommission old infrastructure

**Option B: In-Place Migration**
- Rename existing files
- Import existing resources
- Apply enterprise configuration

## Migration Steps

### Option A: Clean Deployment

#### Step 1: Prepare Enterprise Configuration
```bash
# Clone or update repository
git pull origin main

# Copy configuration template
cp terraform-enterprise.tfvars.example terraform-enterprise.tfvars

# Edit with your current settings
vim terraform-enterprise.tfvars
```

#### Step 2: Configure Network Settings
Use your existing network configuration:
```hcl
# In terraform-enterprise.tfvars
hub_address_space    = "10.0.0.0/16"    # Keep existing
dev_address_space    = "10.10.0.0/16"   # Keep existing  
prod_address_space   = "10.20.0.0/16"   # Keep existing

# VPN settings (IMPORTANT: Keep these exactly as they are!)
aws_gateway_address  = "13.239.236.178"
aws_address_spaces   = ["172.31.0.0/16"]
vpn_shared_key       = "your-existing-shared-key"
```

#### Step 3: Deploy Enterprise Landing Zone
```bash
# Set environment variables
export TF_VAR_vpn_shared_key="your-existing-shared-key"

# Deploy using script
./deploy-enterprise.sh deploy

# Or manually
terraform init
terraform plan -var-file="terraform-enterprise.tfvars"
terraform apply -var-file="terraform-enterprise.tfvars"
```

#### Step 4: Validate Connectivity
```bash
# Check VPN connection
az network vpn-connection show \
  --name entlz-aws-connection \
  --resource-group entlz-prod-rg

# Test connectivity from new environment
# (Use Azure Bastion to access VMs and test ping to AWS)
```

#### Step 5: Migrate Workloads
- Update DNS records to point to new infrastructure
- Migrate VMs using Azure Site Recovery or manual process
- Update application configurations
- Test all connectivity and functionality

#### Step 6: Decommission Old Infrastructure
```bash
# In old directory
terraform destroy
```

### Option B: In-Place Migration

#### Step 1: Backup and Rename
```bash
# Backup current files
cp main.tf main-original.tf
cp variables.tf variables-original.tf
cp outputs.tf outputs-original.tf

# Use enterprise files
cp main-enterprise.tf main.tf
cp variables-enterprise.tf variables.tf
cp outputs-enterprise.tf outputs.tf
```

#### Step 2: Update State (Advanced)
```bash
# This requires careful state manipulation
# Consider using terraform import for new resources
# and terraform state mv for renamed resources

# Example state moves (adjust for your resources)
terraform state mv azurerm_virtual_network.hub_vnet module.hub_network.azurerm_virtual_network.hub
terraform state mv azurerm_virtual_network.dev_vnet module.spoke_networks[\"dev\"].azurerm_virtual_network.spoke
```

#### Step 3: Plan and Apply
```bash
terraform plan -var-file="terraform-enterprise.tfvars"
# Review changes carefully - should be mostly additions
terraform apply -var-file="terraform-enterprise.tfvars"
```

## Configuration Mapping

### Original → Enterprise

| Original | Enterprise | Notes |
|----------|------------|-------|
| `main.tf` | `main-enterprise.tf` | Modular architecture |
| `variables.tf` | `variables-enterprise.tf` | Enhanced variables |
| `outputs.tf` | `outputs-enterprise.tf` | Comprehensive outputs |
| Single file | Module structure | Separated concerns |
| Basic NSGs | Enhanced security | Granular rules |
| No Key Vault | Integrated secrets | Centralized management |

### Network Mapping
```
Original Hub-Spoke → Enterprise Landing Zone

Hub VNet (10.0.0.0/16)
├── GatewaySubnet → modules/networking/hub (unchanged)
├── AzureFirewallSubnet → modules/security/firewall
├── AzureBastionSubnet → modules/networking/hub
└── [New] Shared Services, Management subnets

Dev Spoke (10.10.0.0/16) → modules/networking/spoke["dev"]
├── default → default subnet
├── [New] application subnet
└── [New] data subnet

Prod Spoke (10.20.0.0/16) → modules/networking/spoke["prod"]
├── default → default subnet  
├── [New] application subnet
└── [New] data subnet

[New] Shared Spoke (10.30.0.0/16) → modules/networking/spoke["shared"]
```

## Post-Migration Tasks

### 1. Security Hardening
```bash
# Update Key Vault network access
az keyvault update --name your-kv-name --default-action Deny

# Review and tighten NSG rules
az network nsg rule list --nsg-name entlz-prod-nsg --resource-group entlz-prod-rg

# Enable diagnostic logging
az monitor diagnostic-settings create \
  --name "firewall-logs" \
  --resource "/subscriptions/.../providers/Microsoft.Network/azureFirewalls/entlz-firewall" \
  --logs '[{"category":"AzureFirewallApplicationRule","enabled":true}]'
```

### 2. Monitoring Setup
```bash
# Enable Network Watcher
az network watcher configure --locations "Australia Southeast" --enabled

# Create connection monitor
az network watcher connection-monitor create \
  --name "hub-to-aws-monitor" \
  --location "Australia Southeast"
```

### 3. Governance
- Apply consistent resource tags
- Set up RBAC permissions per spoke
- Configure cost management alerts
- Document network architecture

## Troubleshooting

### Common Migration Issues

#### 1. VPN Connection Fails After Migration
```bash
# Check connection status
az network vpn-connection show --name connection-name --resource-group rg-name

# Verify shared key matches
# Check NSG rules allow VPN traffic (UDP 500, 4500)
# Confirm route tables are correct
```

#### 2. DNS Resolution Issues
```bash
# Check private DNS zone links
az network private-dns link vnet list --zone-name internal.corp --resource-group rg-name

# Verify VM DNS settings
az vm show --name vm-name --resource-group rg-name --query "osProfile.linuxConfiguration.provisionVMAgent"
```

#### 3. Module Import Errors
```bash
# If state import fails, consider selective import
terraform import 'module.hub_network.azurerm_virtual_network.hub' /subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/hub-vnet

# Or use terraform state rm and let Terraform recreate
terraform state rm azurerm_resource.name
```

### Rollback Plan

If migration fails:

1. **Stop new deployment**
   ```bash
   terraform destroy -var-file="terraform-enterprise.tfvars"
   ```

2. **Restore original configuration**
   ```bash
   cp main-original.tf main.tf
   cp variables-original.tf variables.tf
   cp outputs-original.tf outputs.tf
   ```

3. **Restore state if needed**
   ```bash
   terraform state push backup-$(date +%Y%m%d).tfstate
   ```

## Validation Checklist

After migration, verify:

- [ ] All VNets and subnets created correctly
- [ ] VPN connection to AWS working
- [ ] DNS resolution functional
- [ ] Firewall rules allowing required traffic
- [ ] NSG rules properly applied
- [ ] Key Vault accessible from management subnet
- [ ] Route tables directing traffic correctly
- [ ] All resources properly tagged
- [ ] Monitoring and logging enabled

## Support

For migration assistance:
1. Review Terraform plan output carefully
2. Test in non-production environment first
3. Keep backups of all configurations
4. Document any custom modifications
5. Consider professional services for complex migrations

The enterprise landing zone provides a robust foundation for your Azure workloads with enhanced security, governance, and scalability.