# Module 1: Lab Setup

This module deploys the simulated on-premises environment used throughout the workshop.

## Resources Deployed

| Resource | OS | Role |
|----------|----|------|
| `vm-dc01` | Windows Server 2022 | Active Directory Domain Controller |
| `vm-web01` | Windows Server 2022 | IIS Web Server |
| `vm-sql01` | Windows Server 2022 | SQL Server 2019 |
| `vm-lnx01` | Ubuntu 20.04 LTS | Linux application server |

## Steps

### 1. Create a Resource Group

```bash
az group create \
  --name rg-migrate-workshop \
  --location eastus
```

### 2. Deploy the Lab Template

```bash
az deployment group create \
  --resource-group rg-migrate-workshop \
  --template-file deploy/main.bicep \
  --parameters @deploy/parameters.json
```

### 3. Verify Deployment

Once the deployment completes (≈ 20 minutes), confirm all four VMs are running:

```bash
az vm list \
  --resource-group rg-migrate-workshop \
  --show-details \
  --query "[].{Name:name, State:powerState}" \
  --output table
```

Expected output:

```
Name       State
---------  --------------
vm-dc01    VM running
vm-web01   VM running
vm-sql01   VM running
vm-lnx01   VM running
```

## Next Module

➡️ [Module 2: Discovery & Assessment](02-discovery-assessment.md)
