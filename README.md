# Azure Enterprise Landing Zone - Hub-Spoke Network Architecture

This is a comprehensive, enterprise-grade Azure Landing Zone implementation focusing on networking and foundation architecture. It transforms the original Hub-Spoke VNet project into a modular, scalable, and secure enterprise solution with room for expansion into identity management, governance, and advanced monitoring capabilities.

## Architecture Overview

![Azure Landing Zone Hub-Spoke Architecture](/screenshots/azure-landing-zone-hub-diagram.svg)
_Architecture diagram created using AWS official icons and Excalidraw_

### Core Components

- **Hub-Spoke Network Topology**: Centralized hub with multiple spoke networks for workload isolation
- **Azure Firewall**: Centralized security and egress filtering
- **VPN Gateway**: Hybrid connectivity with Point-to-Site and Site-to-Site VPN
- **Network Security Groups**: Granular network security controls
- **Private DNS**: Internal name resolution across the landing zone
- **Key Vault**: Centralized secrets management
- **Modular Terraform**: Reusable infrastructure components

### Network Design

```
Hub VNet (10.0.0.0/16)
├── Gateway Subnet (10.0.0.0/24)      - VPN Gateway
├── Firewall Subnet (10.0.1.0/24)     - Azure Firewall
├── Bastion Subnet (10.0.2.0/24)      - Azure Bastion
├── Shared Services (10.0.3.0/24)     - Key Vault, DNS
└── Management (10.0.4.0/24)          - Management tools

Spoke VNets
├── Dev (10.10.0.0/16)
│   ├── Default (10.10.0.0/24)
│   ├── Application (10.10.1.0/24)
│   └── Data (10.10.2.0/24)
├── Prod (10.20.0.0/16)
│   ├── Default (10.20.0.0/24)
│   ├── Application (10.20.1.0/24)
│   └── Data (10.20.2.0/24)
└── Shared (10.30.0.0/16)
    └── Default (10.30.0.0/24)
```

## Module Structure

```
modules/
├── networking/
│   ├── hub/           - Hub VNet with core subnets
│   └── spoke/         - Spoke VNet with workload subnets
├── security/
│   ├── firewall/      - Azure Firewall with rules
│   └── nsg/           - Network Security Groups
└── foundation/
    ├── keyvault/      - Key Vault for secrets
    ├── dns/           - Private DNS zones
    └── vpn/           - VPN Gateway and connections
```

## Enterprise Features

### Security

- **Defense in Depth**: Multiple security layers (Firewall, NSGs, Private Endpoints)
- **Zero Trust Network**: Deny-by-default with explicit allow rules
- **Secrets Management**: Centralized Key Vault with network isolation
- **Audit Logging**: Comprehensive logging for compliance

### Networking

- **Forced Tunneling**: All internet traffic through Azure Firewall
- **Private Endpoints**: Secure access to Azure services
- **Hybrid Connectivity**: VPN Gateway for on-premises integration
- **DNS Resolution**: Private DNS for internal services

### Governance

- **Resource Tagging**: Consistent tagging strategy
- **RBAC Ready**: Modular design supports granular permissions
- **Cost Management**: Resource grouping by workload and environment
- **Compliance**: Network security standards implementation

## Deployment Guide

### Prerequisites

1. **Azure CLI** logged in with appropriate permissions
2. **Terraform** >= 1.0 installed
3. **Contributor** role on target subscription
4. **Key Vault Administrator** role for secrets management

### Quick Start

1. **Clone and Initialize**

   ```bash
   git clone <repository>
   cd az-hubspoke
   terraform init
   ```

2. **Configure Variables**

   ```bash
   cp terraform-enterprise.tfvars.example terraform-enterprise.tfvars
   # Edit terraform-enterprise.tfvars with your values
   ```

3. **Set VPN Shared Key**

   ```bash
   export TF_VAR_vpn_shared_key="your-secure-shared-key"
   ```

4. **Deploy Infrastructure**
   ```bash
   terraform plan -var-file="terraform-enterprise.tfvars"
   terraform apply -var-file="terraform-enterprise.tfvars"
   ```

### Configuration Options

#### Network Sizing

- **Small**: Hub /20, Spokes /24 (for labs/dev)
- **Medium**: Hub /16, Spokes /20 (for production)
- **Large**: Hub /12, Spokes /16 (for enterprise)

#### Security Tiers

- **Standard**: Basic firewall and NSG rules
- **Premium**: Advanced threat protection and analytics
- **Enterprise**: Full compliance and monitoring suite

#### Connectivity Options

- **VPN Only**: Site-to-Site and Point-to-Site VPN
- **ExpressRoute**: Dedicated private connectivity
- **Hybrid**: Both VPN and ExpressRoute for redundancy

## Security Baseline

### Network Security Groups

- **Default Deny**: All inbound traffic denied by default
- **Bastion Access**: SSH/RDP only through Azure Bastion
- **Service-Specific**: Tailored rules per workload type

### Azure Firewall Rules

- **Application Rules**: FQDN-based filtering for outbound traffic
- **Network Rules**: IP-based filtering for internal traffic
- **Threat Intelligence**: Automatic blocking of malicious IPs

### Key Vault Security

- **Network Isolation**: Private endpoints only
- **Access Policies**: Least privilege access
- **Audit Logging**: All access logged and monitored

## Monitoring and Compliance

### Network Monitoring

- **Network Watcher**: Traffic analytics and diagnostics
- **Flow Logs**: NSG traffic logging
- **Connection Monitor**: Connectivity testing

### Security Monitoring

- **Azure Security Center**: Security posture assessment
- **Sentinel Integration**: SIEM for security events
- **Compliance Dashboard**: Regulatory compliance tracking

## Customization

### Adding New Spokes

```hcl
# In terraform-enterprise.tfvars
spoke_configs = {
  dev    = { address_space = "10.10.0.0/16" }
  prod   = { address_space = "10.20.0.0/16" }
  shared = { address_space = "10.30.0.0/16" }
  test   = { address_space = "10.40.0.0/16" }  # New spoke
}
```

### Custom NSG Rules

```hcl
nsg_rules = {
  prod = {
    AllowDatabase = {
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "1433"
      source_address_prefix      = "10.20.1.0/24"
      destination_address_prefix = "10.20.2.0/24"
    }
  }
}
```

## Migration from Original

To migrate from the original hub-spoke implementation:

1. **Backup Current State**

   ```bash
   terraform state pull > backup.tfstate
   ```

2. **Update Configuration**

   ```bash
   # Use main-enterprise.tf instead of main.tf
   mv main.tf main-original.tf
   mv main-enterprise.tf main.tf
   mv variables-enterprise.tf variables.tf
   mv outputs-enterprise.tf outputs.tf
   ```

3. **Import Existing Resources** (if needed)
   ```bash
   terraform import azurerm_resource_group.main /subscriptions/.../resourceGroups/...
   ```

## Cost Optimization

### Resource Sizing

- **VPN Gateway**: Start with VpnGw1, scale as needed
- **Azure Firewall**: Use Standard tier for most workloads
- **Key Vault**: Standard tier sufficient for most scenarios

### Automation

- **Auto-shutdown**: Configure VM auto-shutdown policies
- **Reserved Instances**: Use for long-running resources
- **Spot Instances**: For development workloads

## Troubleshooting

### Common Issues

1. **VPN Connection Fails**

   - Check shared key matches on both ends
   - Verify NSG rules allow VPN traffic
   - Confirm routing tables are correct

2. **DNS Resolution Issues**

   - Verify private DNS zone links
   - Check conditional forwarders
   - Validate DNS server settings

3. **Firewall Blocking Traffic**
   - Review application and network rules
   - Check threat intelligence feeds
   - Verify source/destination addresses

### Diagnostic Commands

```bash
# Check VPN status
az network vpn-connection show --name connection-name --resource-group rg-name

# Test DNS resolution
nslookup internal.corp

# Check firewall logs
az monitor activity-log list --resource-group rg-name
```

## Support and Maintenance

### Regular Tasks

- **Security Updates**: Monthly review of firewall rules
- **Capacity Planning**: Quarterly network utilization review
- **Compliance Audits**: Annual security and compliance assessment

### Monitoring Alerts

- **VPN Connectivity**: Alert on connection failures
- **Firewall Health**: Monitor firewall availability
- **Key Vault Access**: Alert on unauthorized access attempts

This enterprise landing zone provides a solid foundation for Azure workloads with enterprise-grade security, networking, and governance capabilities.

## Roadmap

### Phase 2: Identity & Access Management

- [ ] Azure Active Directory Domain Services
- [ ] Domain controller deployment in management subnet
- [ ] Integration with existing Private DNS zones
- [ ] RBAC policies per spoke environment
- [ ] Hybrid identity with on-premises AD
- [ ] Conditional access policies

### Phase 3: Governance & Compliance

- [ ] Azure Policy implementation
- [ ] Cost management and budgets
- [ ] Compliance dashboards
- [ ] Automated backup policies
- [ ] Security Center integration
- [ ] Sentinel SIEM deployment

### Phase 4: Monitoring & Operations

- [ ] Network Watcher deployment
- [ ] Application Insights integration
- [ ] Automated alerting and remediation
- [ ] Performance monitoring dashboards
- [ ] Capacity planning automation
