# Azure Migrate & Arc Workshop

> **End-to-End Azure Migration & Arc Workshop** — One-click deploy on-prem lab with AD, IIS, SQL Server, and Linux.

## Overview

This workshop guides you through a complete Azure migration journey using **Azure Migrate** and **Azure Arc**. You will learn how to:

- Discover and assess on-premises workloads (Windows Server with IIS, SQL Server, Linux VMs, Active Directory)
- Migrate servers and databases to Azure using Azure Migrate
- Onboard on-premises and multi-cloud resources to Azure Arc for unified management

## Prerequisites

- An active Azure subscription (Contributor or Owner access)
- Azure CLI (`az`) installed — [Install guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- PowerShell 7+ (for Windows scripts)
- Basic familiarity with Azure Portal and virtual machines

## Lab Architecture

```
On-Premises Lab
├── Domain Controller  (Windows Server 2022 + Active Directory)
├── Web Server         (Windows Server 2022 + IIS)
├── Database Server    (Windows Server 2022 + SQL Server 2019)
└── Linux Server       (Ubuntu 20.04 LTS)
```

All lab VMs can be deployed with a single ARM template (see [`deploy/`](deploy/)).

## Modules

| # | Module | Description |
|---|--------|-------------|
| 1 | [Lab Setup](docs/01-lab-setup.md) | Deploy the on-premises simulation environment |
| 2 | [Discovery & Assessment](docs/02-discovery-assessment.md) | Install Azure Migrate appliance and assess workloads |
| 3 | [Server Migration](docs/03-server-migration.md) | Replicate and migrate VMs to Azure |
| 4 | [Database Migration](docs/04-database-migration.md) | Migrate SQL Server databases using Azure Database Migration Service |
| 5 | [Azure Arc Onboarding](docs/05-arc-onboarding.md) | Connect on-premises and migrated servers to Azure Arc |
| 6 | [Arc-enabled Management](docs/06-arc-management.md) | Apply policies, updates, and monitoring via Azure Arc |

## Quick Start

```bash
# 1. Clone this repository
git clone https://github.com/hariskhurshid12111/azure-migrate-and-arc-workshop.git
cd azure-migrate-and-arc-workshop

# 2. Log in to Azure
az login

# 3. Deploy the lab environment
az deployment sub create \
  --location eastus \
  --template-file deploy/main.bicep \
  --parameters @deploy/parameters.json
```

## Contributing

Pull requests are welcome! Please open an issue first to discuss proposed changes.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
