# 🏗️ Lab Architecture

## Overview

The Azure Migrate & Arc Workshop deploys a **nested Hyper-V environment** inside a single Azure VM. This simulates an on-premises datacenter running the fictional company **HarisKhurshidLTD**.

---

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│                        AZURE SUBSCRIPTION                            │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │                    Resource Group                               │  │
│  │                                                                  │  │
│  │  ┌──────────────────────────────────────────────────────────┐  │  │
│  │  │           HKLTDHost-{studentName}                         │  │  │
│  │  │           Windows Server 2019 Datacenter                  │  │  │
│  │  │           Standard_D8s_v3 (8 vCPU / 32 GB RAM)           │  │  │
│  │  │           OS Disk: 128 GB | Data Disk (F:): 256 GB       │  │  │
│  │  │           Hyper-V Role Enabled                            │  │  │
│  │  │                                                            │  │  │
│  │  │  ┌──────────────────────────────────────────────────┐    │  │  │
│  │  │  │       InternalNATSwitch (192.168.100.0/24)       │    │  │  │
│  │  │  │       Gateway: 192.168.100.1                      │    │  │  │
│  │  │  │       NAT: Internet access for nested VMs         │    │  │  │
│  │  │  │                                                    │    │  │  │
│  │  │  │  ┌────────────────────────────────────────────┐  │    │  │  │
│  │  │  │  │         hariskhurshidltd-dc                 │  │    │  │  │
│  │  │  │  │         192.168.100.10                      │  │    │  │  │
│  │  │  │  │         Windows Server 2019                 │  │    │  │  │
│  │  │  │  │         AD DS + DNS + DHCP                  │  │    │  │  │
│  │  │  │  │         4 GB RAM | 2 vCPU                   │  │    │  │  │
│  │  │  │  │         Gen 2 | Secure Boot: ON             │  │    │  │  │
│  │  │  │  └────────────────────────────────────────────┘  │    │  │  │
│  │  │  │                                                    │    │  │  │
│  │  │  │  ┌────────────────────────────────────────────┐  │    │  │  │
│  │  │  │  │         hariskhurshidltdweb1                │  │    │  │  │
│  │  │  │  │         192.168.100.20                      │  │    │  │  │
│  │  │  │  │         Windows Server 2019                 │  │    │  │  │
│  │  │  │  │         IIS + ASP.NET Web Application       │  │    │  │  │
│  │  │  │  │         4 GB RAM | 2 vCPU                   │  │    │  │  │
│  │  │  │  │         Gen 2 | Secure Boot: ON             │  │    │  │  │
│  │  │  │  └────────────────────────────────────────────┘  │    │  │  │
│  │  │  │                                                    │    │  │  │
│  │  │  │  ┌────────────────────────────────────────────┐  │    │  │  │
│  │  │  │  │         hariskhurshidltdweb2                │  │    │  │  │
│  │  │  │  │         192.168.100.21                      │  │    │  │  │
│  │  │  │  │         Windows Server 2019                 │  │    │  │  │
│  │  │  │  │         IIS + ASP.NET Web Application       │  │    │  │  │
│  │  │  │  │         4 GB RAM | 2 vCPU                   │  │    │  │  │
│  │  │  │  │         Gen 2 | Secure Boot: ON             │  │    │  │  │
│  │  │  │  └────────────────────────────────────────────┘  │    │  │  │
│  │  │  │                                                    │    │  │  │
│  │  │  │  ┌────────────────────────────────────────────┐  │    │  │  │
│  │  │  │  │         hariskhurshidltdsql1                │  │    │  │  │
│  │  │  │  │         192.168.100.30                      │  │    │  │  │
│  │  │  │  │         Windows Server 2019                 │  │    │  │  │
│  │  │  │  │         SQL Server 2019 Standard            │  │    │  │  │
│  │  │  │  │         4 GB RAM | 2 vCPU                   │  │    │  │  │
│  │  │  │  │         Gen 2 | Secure Boot: ON             │  │    │  │  │
│  │  │  │  └────────────────────────────────────────────┘  │    │  │  │
│  │  │  │                                                    │    │  │  │
│  │  │  │  ┌────────────────────────────────────────────┐  │    │  │  │
│  │  │  │  │         hariskhurshidltdlinux1              │  │    │  │  │
│  ��  │  │  │         192.168.100.40                      │  │    │  │  │
│  │  │  │  │         Ubuntu 22.04 LTS                    │  │    │  │  │
│  │  │  │  │         Apache / Nginx Web Server           │  │    │  │  │
│  │  │  │  │         2 GB RAM | 2 vCPU                   │  │    │  │  │
│  │  │  │  │         Gen 2 | Secure Boot: OFF            │  │    │  │  │
│  │  │  │  └────────────────────────────────────────────┘  │    │  │  │
│  │  │  │                                                    │    │  │  │
│  │  │  └──────────────────────────────────────────────────┘    │  │  │
│  │  └──────────────────────────────────────────────────────────┘  │  │
│  │                                                                  │  │
│  │  Supporting Resources:                                           │  │
│  │  ├── NSG (Allow RDP 3389, HTTP 80)                              │  │
│  │  ├── Virtual Network (10.0.0.0/16)                              │  │
│  │  ├── Subnet (10.0.0.0/24)                                      │  │
│  │  ├── NIC (Accelerated Networking + IP Forwarding)               │  │
│  │  └── Dynamic IP with DNS label                          │  │
│  └────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Network Architecture

### Azure-Level Networking

| Component | Value |
|-----------|-------|
| VNet Address Space | 10.0.0.0/16 |
| Subnet | 10.0.0.0/24 |
| Host VM IP | Dynamic (Azure-assigned) |
| DNS Label | hkltdhost-{studentname}.{region}.cloudapp.azure.com |
| NSG Rules | RDP (3389), HTTP (80) |

### Nested Hyper-V Networking

| Component | Value |
|-----------|-------|
| Virtual Switch | InternalNATSwitch |
| Switch Type | Internal + NAT |
| Subnet | 192.168.100.0/24 |
| Gateway | 192.168.100.1 (Host adapter) |
| NAT Name | InternalNat |
| DHCP Scope | 192.168.100.16 - 192.168.100.254 |
| DHCP Exclusion | 192.168.100.1 - 192.168.100.15 |
| DNS (DHCP option) | 168.63.129.16 (Azure DNS) |

### VM IP Assignments (Static)

| VM | IP Address | MAC |
|----|-----------|-----|
| hariskhurshidltd-dc | 192.168.100.10 | Auto-assigned |
| hariskhurshidltdweb1 | 192.168.100.20 | Auto-assigned |
| hariskhurshidltdweb2 | 192.168.100.21 | Auto-assigned |
| hariskhurshidltdsql1 | 192.168.100.30 | Auto-assigned |
| hariskhurshidltdlinux1 | 192.168.100.40 | Auto-assigned |

---

## Active Directory Architecture

```
Forest: hariskhurshidltd.local
│
└── Domain: hariskhurshidltd.local
    ├── NetBIOS: HARISKLTD
    ├── Domain Controller: hariskhurshidltd-dc
    ├── Forest Functional Level: Windows Server 2016
    ├── Domain Functional Level: Windows Server 2016
    │
    ├── DNS Zones:
    │   ├── hariskhurshidltd.local (Forward Lookup)
    │   └── 100.168.192.in-addr.arpa (Reverse Lookup)
    │
    ├── Organizational Units:
    │   ├── OU=Servers
    │   │   ├── hariskhurshidltdweb1
    │   │   ├── hariskhurshidltdweb2
    │   │   └── hariskhurshidltdsql1
    │   └── OU=ServiceAccounts
    │       └── svc-sql (SQL Service Account)
    │
    └── Domain Members:
        ├── hariskhurshidltdweb1 (Windows - domain joined)
        ├── hariskhurshidltdweb2 (Windows - domain joined)
        └── hariskhurshidltdsql1 (Windows - domain joined)
        (hariskhurshidltdlinux1 is NOT domain joined)
```

---

## Application Architecture

### Web Application (IIS + ASP.NET)

```
┌─────────────┐     HTTP      ┌─────────────┐     SQL      ┌─────────────┐
│   Client     │ ──────────── │   Web1/Web2  │ ──────────── │    SQL1     │
│  (Browser)   │   Port 80    │    IIS 10    │  Port 1433   │  SQL 2019   │
└─────────────┘               │   ASP.NET    │              │             │
                              └─────────────┘              └─────────────┘
```

| Component | Details |
|-----------|---------|
| Web Server | IIS 10 on Windows Server 2019 |
| Framework | ASP.NET (Classic / .NET Framework) |
| Load Balancing | Manual (2 web servers, not load balanced) |
| Database | SQL Server 2019 Standard |
| DB Connection | SQL Authentication (webuser / WebP@ss123!) |
| SA Account | sa / P@ssw0rd123! |
| Web URL | http://192.168.100.20 |

---

## Storage Architecture

### Azure Host VM

| Disk | Size | Type | Drive | Purpose |
|------|------|------|-------|---------|
| OS Disk | 128 GB | Premium SSD (P10) | C: | Windows Server 2019 |
| Data Disk | 256 GB | Premium SSD (P15) | F: | VM VHDs + Downloads |

### Data Disk Layout (F:)

```
F:\
├── VirtualMachines\
│   ├── hariskhurshidltd-dc\
│   │   └── hariskhurshidltd-dc.vhdx
│   ├── hariskhurshidltdweb1\
│   │   └── hariskhurshidltdweb1.vhdx
│   ├── hariskhurshidltdweb2\
│   │   └── hariskhurshidltdweb2.vhdx
│   ├── hariskhurshidltdsql1\
│   │   └── hariskhurshidltdsql1.vhdx
│   └── hariskhurshidltdlinux1\
│       └── hariskhurshidltdlinux1.vhdx
└── TempDownloads\          (cleaned after extraction)
```

### Blob Storage (Source)

| URL | https://hariskhurshid.blob.core.windows.net/hariskhurshidltd |
|-----|------|
| hariskhurshidltd-dc.7z | Domain Controller VM image |
| hariskhurshidltdweb1.7z | Web Server 1 VM image |
| hariskhurshidltdweb2.7z | Web Server 2 VM image |
| hariskhurshidltdsql1.7z | SQL Server VM image |
| hariskhurshidltdlinux1.7z | Linux Server VM image |
| 7z2600-x64.exe | 7-Zip installer |
| BootstrapHarisKhurshidLTDHost.ps1 | Bootstrap script |
| PostRebootConfigure.ps1 | Post-reboot script |

---

## Deployment Flow

```
User clicks "Deploy to Azure"
         │
         ▼
┌─────────────────────────┐
│  1. ARM Template Deploy  │  Creates: VNet, NSG, NIC, PIP, VM
│     (~10 minutes)        │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  2. CustomScriptExt      │  Runs: BootstrapHarisKhurshidLTDHost.ps1
│     (~25-35 minutes)     │
│                           │  - Disable IE ESC
│                           │  - Install Chrome
│                           │  - Format F: drive
│                           │  - Install 7-Zip (/S flag)
│                           │  - Download 5 VM .7z files
│                           │  - Decompress all VMs
│                           │  - Configure DHCP
│                           │  - Create desktop shortcuts
│                           │  - Register scheduled task
│                           │  - Install Hyper-V + RESTART
└────────────┬────────────┘
             │
             ▼  (automatic restart)
             │
┌─────────────────────────┐
│  3. PostRebootConfigure  │  Runs via Scheduled Task
│     (~5-10 minutes)      │
│                           │  - Wait for vmms service
│                           │  - Create InternalNATSwitch
│                           │  - Configure NAT (192.168.100.0/24)
│                           │  - Create 5 Gen2 VMs
│                           │  - Start DC first (wait 150s)
│                           │  - Start remaining 4 VMs
│                           │  - Remove scheduled task
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  4. LAB READY!           │  Total time: ~45-60 minutes
│                           │
│  RDP into host VM        │
│  Open Hyper-V Manager    │
│  Browse http://192.168.100.20
└─────────────────────────┘
```

---

## Security Considerations

> ⚠️ **This is a LAB environment — NOT for production use!**

| Item | Details |
|------|---------|
| NSG | RDP open to all (restrict to your IP in production) |
| Passwords | Simple lab passwords — change for any real use |
| SQL Auth | Mixed mode authentication enabled |
| IE ESC | Disabled for convenience |
| Windows Update | Disabled to save deployment time |
| Secure Boot | OFF for Linux VM only |

---

## Resource Sizing

### Minimum Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| Azure VM Size | Standard_D8s_v3 | Standard_D16s_v3 |
| vCPUs | 8 | 16 |
| RAM | 32 GB | 64 GB |
| Data Disk | 256 GB | 256 GB |

### Nested VM Resource Usage

| VM | RAM | vCPU | Estimated VHDX |
|----|-----|------|----------------|
| hariskhurshidltd-dc | 4 GB | 2 | ~15-20 GB |
| hariskhurshidltdweb1 | 4 GB | 2 | ~15-20 GB |
| hariskhurshidltdweb2 | 4 GB | 2 | ~15-20 GB |
| hariskhurshidltdsql1 | 4 GB | 2 | ~20-30 GB |
| hariskhurshidltdlinux1 | 2 GB | 2 | ~8-12 GB |
| **Total** | **18 GB** | **10** | **~73-102 GB** |

---

*Maintained by Haris Khurshid, MCT — [GitHub](https://github.com/hariskhurshid12111)*
