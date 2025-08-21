# Hybrid Cloud VPN Lab: Azure to AWS with Terraform + strongSwan

This lab demonstrates a full hybrid cloud setup with a site-to-site IPsec VPN connecting Microsoft Azure and AWS, using Terraform and strongSwan. The core goal: simulate real-world hybrid connectivity, routing, and security in a hub-and-spoke Azure topology.

---

## ✅ What You Built

- **Azure Hub-Spoke Network**

  - Hub VNet: contains VPN Gateway, Azure Firewall, Bastion
  - Spoke VNet: contains production VM (10.20.0.4)
  - VNet Peering:

    - `hub -> spoke`: `allow_gateway_transit = true`
    - `spoke -> hub`: `use_remote_gateways = true`

- **AWS EC2 Instance (172.31.9.161)**

  - Acts as the "on-prem" site
  - Runs strongSwan IPsec VPN server

- **Site-to-Site VPN**

  - Azure VPN Gateway ↔ strongSwan
  - `leftsubnet = 172.31.0.0/16`, `rightsubnet = 10.20.0.0/16`

---

## 🛠️ Final Validated Features

- [x] Tunnel is **UP and STABLE** (`ipsec statusall` confirms)
- [x] Ping **from AWS to Azure** ✅
- [x] Ping **from Azure to AWS** ✅
- [x] Screenshots captured for:

  - Ping tests
  - NSG + SG configurations
  - Azure route tables

---

## 🧹 Cleanup / Tighten Security

### Azure NSG (spoke subnet)

- ✅ Keep: ICMP from `172.31.0.0/16`
- ✅ Optional: outbound to `172.31.0.0/16`
- ❌ Remove: any overly permissive outbound/inbound rules

### AWS Security Group

- ✅ Keep: UDP 500/4500 from Azure VPN IP
- ✅ Allow: ICMP from `10.20.0.0/16` (or limit to known IPs)
- ❌ Remove: wide-open "All traffic" rules unless testing

---

## 📦 Expansion Plan (Optional Next Phase)

### 🔍 Splunk Integration

- Deploy a Splunk container or EC2-based instance
- Forward VPN logs from strongSwan EC2:

  ```bash
  /var/log/syslog or /var/log/charon.log
  ```

- Parse and visualize:

  - Tunnel uptime / downtime
  - Failed IKE attempts
  - Traffic volume over VPN

### 🔧 Ansible

- Automate EC2 strongSwan config
- Use dynamic inventory from Azure + AWS for hybrid config push

### ☁️ Prometheus + Node Exporter

- Install exporters on Azure and AWS VMs
- Deploy Prometheus in Azure
- Scrape metrics across VPN for unified observability

### 🧑‍💼 Active Directory

- Extend lab to simulate hybrid AD:

  - Deploy AD on AWS
  - Join Azure VM to AWS AD over tunnel

---

## 🧠 Portfolio Tips

- Turn this into a post: _"Building Hybrid Cloud Connectivity: Azure + AWS VPN Lab with Terraform and strongSwan"_
- Include:

  - Diagrams
  - Code snippets
  - Screenshots
  - Troubleshooting notes
  - Expansion plan (Splunk, Ansible, etc.)

> ✅ This project now serves as a proof point for your cloud networking, infrastructure-as-code, and platform readiness.

---

## 🔚 When You're Done

```bash
terraform destroy  # cleanup Azure resources
echo 'terminate EC2 manually or via AWS CLI'
```

Ready to take this further or polish it up as a case study? Just say the word!
