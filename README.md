# 🏢 Azure Migrate & Arc Workshop

**End-to-End Azure Migration & Hybrid Management Workshop**

![Azure](https://img.shields.io/badge/Microsoft-Azure-0078D4?logo=microsoftazure&logoColor=white)
![Hyper-V](https://img.shields.io/badge/Hyper--V-Nested-blue)
![ARM](https://img.shields.io/badge/ARM-Template-orange)
![License](https://img.shields.io/badge/License-MIT-green)
![MCT](https://img.shields.io/badge/MCT-Haris%20Khurshid-red)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhariskhurshid12111%2Fazure-migrate-and-arc-workshop%2Fmain%2Fdeploy%2Fazuredeploy.json)

---

## 📋 Overview

This workshop provides a **one-click deployable on-premises lab environment** using nested Hyper-V in Azure. It deploys a fully configured enterprise environment with Active Directory, IIS web servers, SQL Server, and Linux — perfect for practicing **Azure Migrate** and **Azure Arc** scenarios.

The lab simulates a real-world company called **HarisKhurshidLTD** running on-premises workloads that need to be assessed, migrated, and managed using Azure services.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure Resource Group                       │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              HKLTDHost VM (Windows Server 2019)          │ │
│  │              Standard_D8s_v3 / Hyper-V Enabled           │ │
│  │  ┌───────────────────────────────────────────────────┐  │ │
│  │  │         InternalNATSwitch (192.168.100.0/24)      │  │ │
│  │  │                                                     │  │ │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐          │  │ │
│  │  │  │   DC     │ │  Web1    │ │  Web2    │          │  │ │
│  │  │  │  .10     │ │  .20     │ │  .21     │          │  │ │
│  │  │  │ AD + DNS │ │ IIS+ASP  │ │ IIS+ASP  │          │  │ │
│  │  │  └──────────┘ └──────────┘ └──────────┘          │  │ │
│  │  │  ┌──────────┐ ┌──────────┐                        │  │ │
│  │  │  │  SQL1    │ │ Linux1   │                        │  │ │
│  │  │  │  .30     │ │  .40     │                        │  │ │
│  │  │  │ SQL 2019 │ │Ubuntu 22 │                        │  │ │
│  │  │  └──────────┘ └──────────┘                        │  │ │
│  │  └───────────────────────────────────────────────────┘  │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## 📚 Workshop Modules

| Module | Title | Description |
|--------|-------|-------------|
| [Module 00](modules/module-00-deploy-environment/) | Deploy Lab Environment | One-click deploy and verify lab |
| [Module 01](modules/module-01-explore-onprem/) | Explore On-Premises | Explore AD, IIS, SQL, Hyper-V |
| [Module 02](modules/module-02-azure-migrate/) | Azure Migrate | Discover, assess, replicate, migrate |
| [Module 03](modules/module-03-azure-arc/) | Azure Arc | Arc-enable servers, SQL, policies |
| [Module 04](modules/module-04-governance/) | Governance & Management | Backup, monitoring, security |

---

## 🖥️ Virtual Machines

| VM Name | IP Address | Role | OS | RAM | CPU |
|---------|-----------|------|-----|-----|-----|
| hariskhurshidltd-dc | 192.168.100.10 | AD Domain Controller + DNS | Windows Server 2019 | 4 GB | 2 |
| hariskhurshidltdweb1 | 192.168.100.20 | IIS Web Server + ASP.NET | Windows Server 2019 | 4 GB | 2 |
| hariskhurshidltdweb2 | 192.168.100.21 | IIS Web Server + ASP.NET | Windows Server 2019 | 4 GB | 2 |
| hariskhurshidltdsql1 | 192.168.100.30 | SQL Server 2019 | Windows Server 2019 | 4 GB | 2 |
| hariskhurshidltdlinux1 | 192.168.100.40 | Linux Server | Ubuntu 22.04 LTS | 2 GB | 2 |

---

## 🔑 Credentials

| Service | Username | Password |
|---------|----------|----------|
| Azure Host VM | localuser | *(set during deployment)* |
| Domain Admin | HARISKLTD\Administrator | P@ssw0rd123! |
| SQL SA | sa | P@ssw0rd123! |
| SQL Web User | webuser | WebP@ss123! |

---

## ⚡ Quick Start

1. Click the **"Deploy to Azure"** button above
2. Fill in: Resource Group, Admin Password, Student Name
3. Wait **45-60 minutes** for full deployment
4. **RDP** into the host VM using the FQDN from deployment outputs
5. Open **Hyper-V Manager** — all 5 VMs should be running
6. Browse to **http://192.168.100.20** to verify the web application

---

## 📝 Prerequisites

- Azure subscription with **Contributor** access
- Ability to deploy **Standard_D8s_v3** or larger VMs
- RDP client (Windows built-in or Microsoft Remote Desktop)
- **~45-60 minutes** for initial deployment

---

## 🎯 Microsoft Exam Objectives Mapping

This workshop covers objectives from the following Microsoft certifications:

| Exam | Areas Covered |
|------|--------------|
| **AZ-104** | VMs, VNets, NSGs, ARM templates, monitoring |
| **AZ-305** | Migration strategy, hybrid architecture |
| **AZ-800** | Hyper-V, AD DS, DNS, DHCP, IIS, file services |
| **AZ-801** | Windows Server hybrid, migration tools |
| **SC-200** | Defender for Cloud, Arc security, Sentinel |

See [docs/exam-mapping.md](docs/exam-mapping.md) for detailed objective mapping.

---

## 💡 Inspiration & Credits

This workshop was inspired by the **Microsoft Cloud Workshop (MCW) — Line of Business Application Migration**, which is no longer maintained and whose deployment resources are no longer accessible.

This project is a **complete rebuild from scratch** featuring:
- ✅ Updated to Windows Server 2019 + SQL Server 2019
- ✅ Custom branded enterprise environment (HarisKhurshidLTD)
- ✅ Modern ARM templates with best practices
- ✅ Pre-configured VMs (no manual setup required)
- ✅ Comprehensive lab exercises covering Migrate + Arc
- ✅ Microsoft certification exam alignment

---

## 👨‍🏫 Author

Created and maintained by **Haris Khurshid**, Microsoft Certified Trainer (MCT)

- 🔗 GitHub: [hariskhurshid12111](https://github.com/hariskhurshid12111)

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
