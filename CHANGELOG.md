# 📋 Changelog

All notable changes to the **Azure Migrate & Arc Workshop** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [1.0.0] - 2026-02-26

### 🎉 Initial Release

#### Added
- One-click **Deploy to Azure** ARM template for nested Hyper-V lab host
- **5 pre-configured virtual machines:**
  - `hariskhurshidltd-dc` — Active Directory Domain Controller + DNS
  - `hariskhurshidltdweb1` — IIS Web Server + ASP.NET
  - `hariskhurshidltdweb2` — IIS Web Server + ASP.NET
  - `hariskhurshidltdsql1` — SQL Server 2019
  - `hariskhurshidltdlinux1` — Ubuntu 22.04 LTS
- **Bootstrap automation** (`BootstrapLabHost.ps1`):
  - Disables IE Enhanced Security
  - Installs Google Chrome
  - Formats F: data drive
  - Installs 7-Zip from blob storage
  - Downloads and decompresses 5 VM images
  - Configures DHCP scope (192.168.100.0/24)
  - Creates desktop shortcuts with lab info
  - Installs Hyper-V with automatic restart
- **Post-reboot automation** (`PostRebootConfigure.ps1`):
  - Creates InternalNATSwitch (192.168.100.0/24)
  - Creates 5 Generation 2 Hyper-V VMs
  - Starts DC first, waits 150s for AD, then starts remaining VMs
  - Self-cleaning scheduled task
- **Workshop modules:**
  - Module 00: Deploy Lab Environment
  - Module 01: Explore On-Premises Environment
  - Module 02: Azure Migrate — Discover, Assess, Migrate
  - Module 03: Azure Arc — Hybrid Server Management
  - Module 04: Governance — Defender, Monitor, Backup
- **Documentation:**
  - Lab architecture diagram and details
  - Troubleshooting guide
  - Microsoft exam objectives mapping (AZ-104, AZ-305, AZ-800, AZ-801, SC-200)
  - Contributing guidelines
- **GitHub templates:**
  - Bug report issue template
  - Feature request issue template

#### Infrastructure
- Azure VM: Windows Server 2019 Datacenter
- OS Disk: 128 GB Premium SSD
- Data Disk: 256 GB Premium SSD
- Default Size: Standard_D8s_v3
- Timezone: Pakistan Standard Time
- Domain: hariskhurshidltd.local
- NetBIOS: HARISKLTD
- Subnet: 192.168.100.0/24
- Storage: https://hariskhurshid.blob.core.windows.net/hariskhurshidltd

---

## [Unreleased]

### Planned
- Module 05: Azure Sentinel integration
- Module 06: Azure Backup and Site Recovery
- Module 07: Azure Update Management
- Linux-specific migration exercises
- Cost estimation calculator
- Video walkthroughs for each module

---

*Maintained by Haris Khurshid, MCT — [GitHub](https://github.com/hariskhurshid12111)*
