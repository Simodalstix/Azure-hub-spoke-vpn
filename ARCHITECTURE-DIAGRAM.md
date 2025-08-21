# Azure Enterprise Landing Zone - Architecture Diagram Guide

## ASCII Architecture Diagram

```
                    ┌─────────────────────────────────────────────────────────────┐
                    │                    AZURE SUBSCRIPTION                       │
                    │                                                             │
    ┌───────────────┼─────────────────────────────────────────────────────────────┼───────────────┐
    │               │                 RESOURCE GROUP                              │               │
    │               │                entlz-prod-rg                               │               │
    │               └─────────────────────────────────────────────────────────────┘               │
    │                                                                                             │
    │  ┌─────────────────────────────────────────────────────────────────────────────────────┐  │
    │  │                           HUB VNET (10.0.0.0/16)                                   │  │
    │  │                                                                                     │  │
    │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────┐ │  │
    │  │  │   Gateway    │  │   Firewall   │  │   Bastion    │  │   Shared     │  │ Mgmt │ │  │
    │  │  │   Subnet     │  │   Subnet     │  │   Subnet     │  │   Services   │  │      │ │  │
    │  │  │10.0.0.0/24   │  │10.0.1.0/24   │  │10.0.2.0/24   │  │10.0.3.0/24   │  │10.0.4│ │  │
    │  │  │              │  │              │  │              │  │              │  │ /24  │ │  │
    │  │  │  [VPN-GW]    │  │  [FIREWALL]  │  │  [BASTION]   │  │  [KEY-VAULT] │  │      │ │  │
    │  │  │      │       │  │      │       │  │              │  │  [DNS-ZONE]  │  │      │ │  │
    │  │  └──────┼───────┘  └──────┼───────┘  └──────────────┘  └──────────────┘  └──────┘ │  │
    │  │         │                 │                                                       │  │
    │  └─────────┼─────────────────┼───────────────────────────────────────────────────────┘  │
    │            │                 │                                                          │
    │            │                 │ ┌─────────────────────────────────────────────────────┐ │
    │            │                 └─┤              ROUTE TABLES                           │ │
    │            │                   │         Force tunnel to Firewall                   │ │
    │            │                   │              0.0.0.0/0 → FW                       │ │
    │            │                   └─────────────────────────────────────────────────────┘ │
    │            │                                                                          │
    │  ┌─────────┼──────────────────────────────────────────────────────────────────────┐  │
    │  │         │                    SPOKE NETWORKS                                     │  │
    │  │         │                                                                      │  │
    │  │  ┌──────▼──────┐        ┌─────────────┐        ┌─────────────┐                │  │
    │  │  │ DEV SPOKE   │        │ PROD SPOKE  │        │SHARED SPOKE │                │  │
    │  │  │10.10.0.0/16 │        │10.20.0.0/16 │        │10.30.0.0/16 │                │  │
    │  │  │             │        │             │        │             │                │  │
    │  │  │┌───────────┐│        │┌───────────┐│        │┌───────────┐│                │  │
    │  │  ││  Default  ││        ││  Default  ││        ││  Default  ││                │  │
    │  │  ││10.10.0/24 ││        ││10.20.0/24 ││        ││10.30.0/24 ││                │  │
    │  │  │└───────────┘│        │└───────────┘│        │└───────────┘│                │  │
    │  │  │┌───────────┐│        │┌───────────┐│        │             │                │  │
    │  │  ││   App     ││        ││   App     ││        │             │                │  │
    │  │  ││10.10.1/24 ││        ││10.20.1/24 ││        │             │                │  │
    │  │  │└───────────┘│        │└───────────┘│        │             │                │  │
    │  │  │┌───────────┐│        │┌───────────┐│        │             │                │  │
    │  │  ││   Data    ││        ││   Data    ││        │             │                │  │
    │  │  ││10.10.2/24 ││        ││10.20.2/24 ││        │             │                │  │
    │  │  │└───────────┘│        │└───────────┘│        │             │                │  │
    │  │  │             │        │             │        │             │                │  │
    │  │  │   [NSG]     │        │   [NSG]     │        │   [NSG]     │                │  │
    │  │  └─────────────┘        └─────────────┘        └─────────────┘                │  │
    │  │                                                                                │  │
    │  └────────────────────────────────────────────────────────────────────────────────┘  │
    │                                                                                       │
    └───────────────────────────────────────────────────────────────────────────────────────┘
                                           │
                                           │ VPN Tunnel
                                           │ (IPSec)
                                           ▼
                    ┌─────────────────────────────────────┐
                    │           ON-PREMISES               │
                    │         AWS VPC                     │
                    │      172.31.0.0/16                  │
                    │                                     │
                    │    [EC2] ──── [strongSwan]          │
                    │              13.239.236.178         │
                    └─────────────────────────────────────┘

LEGEND:
[VPN-GW]    = VPN Gateway
[FIREWALL]  = Azure Firewall  
[BASTION]   = Azure Bastion
[KEY-VAULT] = Key Vault
[DNS-ZONE]  = Private DNS Zone
[NSG]       = Network Security Group
```

## Azure Icons Needed for Excalidraw

### Core Infrastructure
- 🏢 **Resource Group** - Azure Resource Group icon
- 🌐 **Virtual Network** - Azure Virtual Network icon
- 🔗 **Subnet** - Subnet icon (rectangle with network symbol)

### Networking Components
- 🚪 **VPN Gateway** - Azure VPN Gateway icon
- 🛡️ **Azure Firewall** - Azure Firewall icon
- 🏰 **Azure Bastion** - Azure Bastion icon
- 🔒 **Network Security Group** - NSG shield icon
- 📋 **Route Table** - Route table icon

### Foundation Services
- 🔐 **Key Vault** - Azure Key Vault icon
- 🌍 **Private DNS Zone** - DNS zone icon
- 📊 **Private Endpoint** - Private endpoint icon

### Connectivity
- ⚡ **VPN Connection** - VPN tunnel/connection icon
- 🔄 **VNet Peering** - Peering connection icon
- 🌐 **Public IP** - Public IP address icon

### External/Hybrid
- ☁️ **AWS Cloud** - AWS cloud icon
- 🖥️ **EC2 Instance** - AWS EC2 icon
- 🔧 **strongSwan** - VPN software icon

### Visual Elements
- 📦 **Containers/Boxes** - For grouping components
- ➡️ **Arrows** - For traffic flow and connections
- 🏷️ **Labels** - For IP ranges and names
- 🎨 **Colors** - Blue for Azure, Orange for AWS, Green for secure connections

## Layout Tips for Excalidraw

1. **Hub-Spoke Layout**: Place Hub VNet in center, spokes around it
2. **Color Coding**: 
   - Blue tones for Azure components
   - Orange for AWS/external
   - Green for secure connections
   - Red for security components
3. **Grouping**: Use containers to group related components
4. **Flow Direction**: Show traffic flow with arrows
5. **IP Addressing**: Label each network segment clearly

## Network Flow Patterns

### Internet Traffic Flow
```
Spoke VM → Route Table → Azure Firewall → Internet
```

### Inter-Spoke Communication
```
Dev Spoke → Hub VNet → Firewall Rules → Prod Spoke
```

### Hybrid Connectivity
```
On-Premises (AWS) → VPN Gateway → Hub VNet → Spoke Networks
```

### Management Access
```
Admin → Azure Bastion → Hub VNet → Spoke VMs
```

## Security Layers

1. **Network Security Groups** - Subnet-level filtering
2. **Azure Firewall** - Centralized security and logging
3. **Route Tables** - Forced tunneling through firewall
4. **Private Endpoints** - Secure access to Azure services
5. **Key Vault** - Centralized secrets management

Sleep well! 😴