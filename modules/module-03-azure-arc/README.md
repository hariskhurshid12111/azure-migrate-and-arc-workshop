# 🌐 Module 03: Azure Arc — Hybrid Server Management

## Overview

In this module, you will use **Azure Arc** to extend Azure management to the on-premises servers of HarisKhurshidLTD. You will onboard Windows and Linux servers to Azure Arc, apply Azure Policy, enable extensions, and manage Arc-enabled SQL Server — all without migrating workloads.

---

## ⏱️ Estimated Time: 90-120 minutes

---

## 🎯 Objectives

After completing this module, you will be able to:

- Understand Azure Arc concepts and use cases
- Generate onboarding scripts for Azure Arc
- Onboard Windows servers to Azure Arc
- Onboard Linux servers to Azure Arc
- Onboard SQL Server to Azure Arc
- Apply Azure Policy to Arc-enabled servers
- Deploy extensions to Arc-enabled servers
- Monitor Arc-enabled servers from the Azure Portal
- Manage hybrid servers through a single pane of glass

---

## 📋 Prerequisites

- Completed [Module 00](../module-00-deploy-environment/) and [Module 01](../module-01-explore-onprem/)
- All 5 nested VMs running with internet access
- Azure subscription with Contributor access
- RDP connection to the Hyper-V host

---

## 🔑 Credentials Reference

| Service | Username | Password |
|---------|----------|----------|
| Domain Admin | HARISKLTD\Administrator | P@ssw0rd123! |
| Linux VM | *(configured during setup)* | *(configured during setup)* |

---

## Concepts: What is Azure Arc?

Azure Arc lets you manage resources **outside of Azure** as if they were Azure resources:

```
┌─────────────────────────────────────────────┐
│                AZURE PORTAL                  │
│         (Single Pane of Glass)               │
│                                               │
│  ┌─────────┐  ┌─────────┐  ┌─────────────┐ │
│  │  Azure   │  │  Azure   │  │  Arc-enabled │ │
│  │  VMs     │  │  SQL DB  │  │  Servers     │ │
│  └─────────┘  └─────────┘  └──────┬──────┘ │
│                                     │        │
└─────────────────────────────────────┼────────┘
                                      │
                          Azure Arc Agent
                                      │
              ┌───────────────────────┼───────────────────────┐
              │            ON-PREMISES DATACENTER              │
              │                                                 │
              │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐        │
              │  │  DC  │ │ Web1 │ │ SQL1 │ │Linux1│        │
              │  │ .10  │ │ .20  │ │ .30  │ │ .40  │        │
              │  └──────┘ └──────┘ └──────┘ └──────┘        │
              └─────────────────────────────────────────────────┘
```

**Key Benefits:**
- Inventory and organize across environments
- Apply Azure Policy for governance
- Enable Azure Monitor for observability
- Use Microsoft Defender for security
- Deploy VM extensions remotely
- Manage SQL Server with Azure services

---

## Exercise 1: Prepare Azure Environment

### Step 1: Register Azure Resource Providers

Open **Azure Cloud Shell** (Bash or PowerShell) and register required providers:

```powershell
# Register resource providers
Register-AzResourceProvider -ProviderNamespace Microsoft.HybridCompute
Register-AzResourceProvider -ProviderNamespace Microsoft.HybridConnectivity
Register-AzResourceProvider -ProviderNamespace Microsoft.GuestConfiguration
Register-AzResourceProvider -ProviderNamespace Microsoft.AzureArcData

# Verify registration
Get-AzResourceProvider -ProviderNamespace Microsoft.HybridCompute | Select-Object ProviderNamespace, RegistrationState
Get-AzResourceProvider -ProviderNamespace Microsoft.HybridConnectivity | Select-Object ProviderNamespace, RegistrationState
```

### Step 2: Create Resource Group for Arc

```powershell
# Create a resource group for Arc-enabled resources
New-AzResourceGroup -Name "rg-hkltd-arc" -Location "EastUS"
```

### Step 3: Create a Service Principal (Optional)

For at-scale onboarding:

```powershell
# Create service principal for Arc onboarding
$sp = New-AzADServicePrincipal -DisplayName "hkltd-arc-onboarding"
$secret = $sp | New-AzADServicePrincipalCredential
Write-Host "App ID: $($sp.AppId)"
Write-Host "Secret: $($secret.SecretText)"
Write-Host "Tenant: $(Get-AzContext | Select-Object -ExpandProperty Tenant | Select-Object -ExpandProperty Id)"

# Assign Azure Connected Machine Onboarding role
New-AzRoleAssignment -ObjectId $sp.Id -RoleDefinitionName "Azure Connected Machine Onboarding" -ResourceGroupName "rg-hkltd-arc"
```

---

## Exercise 2: Generate Onboarding Script

### Step 1: Navigate to Azure Arc

1. Open [Azure Portal](https://portal.azure.com)
2. Search for **Azure Arc** → Click **Azure Arc**
3. Click **Servers** → **Add**

### Step 2: Select Onboarding Method

Choose: **Add a single server** (for lab purposes)

> For production, you would choose "Add multiple servers" with a service principal

### Step 3: Configure and Generate Script

Fill in:

| Setting | Value |
|---------|-------|
| Subscription | Your subscription |
| Resource Group | `rg-hkltd-arc` |
| Region | East US |
| Operating System | Windows (first) |
| Connectivity | Public endpoint |

Click **Generate script**

### Step 4: Copy the Script

1. **Copy** the entire PowerShell script
2. **Save it** — you'll need it for multiple VMs

The script will look something like:

```powershell
# Download and install the Azure Connected Machine agent
try {
    # Download the installation package
    Invoke-WebRequest -Uri "https://aka.ms/azcmagent-windows" -TimeoutSec 30 -OutFile "$env:TEMP\install_windows_azcmagent.ps1"
    
    # Install the agent
    & "$env:TEMP\install_windows_azcmagent.ps1"
    if ($LASTEXITCODE -ne 0) { exit 1 }
    
    # Connect to Azure
    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect `
        --service-principal-id "<YOUR_APP_ID>" `
        --service-principal-secret "<YOUR_SECRET>" `
        --resource-group "rg-hkltd-arc" `
        --tenant-id "<YOUR_TENANT_ID>" `
        --location "eastus" `
        --subscription-id "<YOUR_SUBSCRIPTION_ID>"
}
catch {
    $logBody = @{subscriptionId="<YOUR_SUBSCRIPTION_ID>";resourceGroup="rg-hkltd-arc";tenantId="<YOUR_TENANT_ID>";location="eastus";correlationId="<CORRELATION_ID>";authType="Token";operation="onboarding";messageType="error";message="$($_.Exception.Message)"}
}
```

---

## Exercise 3: Onboard Windows Servers

### Step 1: Onboard the Domain Controller

1. In Hyper-V Manager, connect to `hariskhurshidltd-dc`
2. Login: `HARISKLTD\Administrator` / `P@ssw0rd123!`
3. Open **PowerShell as Administrator**
4. **Verify internet connectivity first:**
   ```powershell
   Test-NetConnection -ComputerName "login.microsoftonline.com" -Port 443
   Test-NetConnection -ComputerName "management.azure.com" -Port 443
   Test-NetConnection -ComputerName "gbl.his.arc.azure.com" -Port 443
   ```
5. **Paste and run** the onboarding script
6. When prompted, authenticate with your Azure credentials
7. Wait for completion — you should see: `Connected successfully`

### Step 2: Verify in Azure Portal

1. Go to **Azure Arc** → **Servers**
2. You should see: `hariskhurshidltd-dc` with status **Connected**

### Step 3: Onboard Web Servers

Repeat for `hariskhurshidltdweb1` and `hariskhurshidltdweb2`:

1. Connect via Hyper-V Manager
2. Login: `HARISKLTD\Administrator` / `P@ssw0rd123!`
3. Open PowerShell as Administrator
4. Run the onboarding script
5. Verify in Azure Portal

### Step 4: Onboard SQL Server VM

1. Connect to `hariskhurshidltdsql1`
2. Login: `HARISKLTD\Administrator` / `P@ssw0rd123!`
3. Run the onboarding script
4. Verify in Azure Portal

### Step 5: Verify All Windows Servers

In Azure Portal → **Azure Arc** → **Servers**:

| Server | Status | Expected |
|--------|--------|----------|
| hariskhurshidltd-dc | Connected ✅ | |
| hariskhurshidltdweb1 | Connected ✅ | |
| hariskhurshidltdweb2 | Connected ✅ | |
| hariskhurshidltdsql1 | Connected ✅ | |

---

## Exercise 4: Onboard Linux Server

### Step 1: Generate Linux Script

1. Go to **Azure Arc** → **Servers** → **Add**
2. Select **Add a single server**
3. Change **Operating System** to **Linux**
4. Generate the script

### Step 2: Connect to Linux VM

1. From the Hyper-V host, SSH to the Linux VM:
   ```powershell
   ssh user@192.168.100.40
   ```
   Or use Hyper-V Manager → Connect

### Step 3: Verify Internet Connectivity

```bash
# Test connectivity to Azure endpoints
curl -s -o /dev/null -w "%{http_code}" https://login.microsoftonline.com
curl -s -o /dev/null -w "%{http_code}" https://management.azure.com
curl -s -o /dev/null -w "%{http_code}" https://gbl.his.arc.azure.com
```

### Step 4: Run the Onboarding Script

```bash
# Download and run the onboarding script
# (Paste the script generated from the portal)

# The script will:
# 1. Download the azcmagent package
# 2. Install it
# 3. Connect to Azure Arc

# Verify installation
azcmagent show
```

### Step 5: Verify in Azure Portal

In **Azure Arc** → **Servers**, you should now see:

| Server | OS | Status |
|--------|----|--------|
| hariskhurshidltd-dc | Windows | Connected ✅ |
| hariskhurshidltdweb1 | Windows | Connected ✅ |
| hariskhurshidltdweb2 | Windows | Connected ✅ |
| hariskhurshidltdsql1 | Windows | Connected ✅ |
| hariskhurshidltdlinux1 | Linux | Connected ✅ |

---

## Exercise 5: Onboard Arc-enabled SQL Server

### Step 1: Navigate to Arc SQL Server

1. In Azure Portal, go to **Azure Arc** → **SQL Server instances**
2. Click **Add**

### Step 2: Install SQL Server Extension

On `hariskhurshidltdsql1` (which is already Arc-enabled):

1. Go to **Azure Arc** → **Servers** → Click `hariskhurshidltdsql1`
2. Click **Extensions** → **Add**
3. Select **SQL Server extension (Microsoft.AzureData.WindowsAgent.SqlServer)**
4. Configure:

| Setting | Value |
|---------|-------|
| SQL Server instance | MSSQLSERVER (default) |
| License type | Pay-as-you-go or License included |

5. Click **Review + create** → **Create**

### Step 3: Verify SQL Server in Arc

1. Go to **Azure Arc** → **SQL Server instances**
2. You should see the SQL instance from `hariskhurshidltdsql1`
3. Click on it to see:
   - Version: SQL Server 2019
   - Edition: Standard
   - Databases: (your databases)

### Step 4: Explore Arc SQL Features

Once onboarded, you can:
- View SQL Server inventory in Azure
- Monitor SQL performance
- Enable Azure Defender for SQL
- Configure automated backups
- Apply Azure Policy for SQL

---

## Exercise 6: Apply Azure Policy

### Step 1: Navigate to Azure Policy

1. Go to **Azure Portal** → **Policy**
2. Click **Assignments** → **Assign policy**

### Step 2: Assign Tag Policy

| Setting | Value |
|---------|-------|
| Scope | Resource Group: `rg-hkltd-arc` |
| Policy definition | Search: "Require a tag on resources" |
| Policy name | `hkltd-require-environment-tag` |
| Tag name | `Environment` |
| Tag value | `Lab` |

### Step 3: Assign Arc-specific Policies

Assign these built-in policies to `rg-hkltd-arc`:

| Policy | Purpose |
|--------|---------|
| **Configure Arc-enabled machines to run Azure Monitor Agent** | Deploy monitoring agent |
| **Configure Arc-enabled SQL Servers with Data Collection Rule** | SQL monitoring |
| **Audit Arc-enabled servers without Log Analytics agent** | Compliance check |
| **Configure prerequisite for Azure Policy Guest Configuration** | Enable guest config |

### Step 4: Check Compliance

1. Go to **Policy** → **Compliance**
2. Filter by scope: `rg-hkltd-arc`
3. Review compliance state for each policy

| Policy | Expected State |
|--------|---------------|
| Require tag | Non-compliant (tags not yet applied) |
| Azure Monitor Agent | Remediating (deploying agent) |
| Guest Configuration | Compliant or Remediating |

### Step 5: Remediate Non-Compliant Resources

1. Click on a non-compliant policy
2. Click **Create remediation task**
3. Select the resources to remediate
4. Click **Remediate**

---

## Exercise 7: Deploy Extensions

### Step 1: Deploy Azure Monitor Agent

For each Arc-enabled server:

1. Go to **Azure Arc** → **Servers** → Click server name
2. Click **Extensions** → **Add**
3. Select **Azure Monitor Agent**
4. Click **Create**

Or use PowerShell for all servers:

```powershell
# Get all Arc-enabled servers in the resource group
$servers = Get-AzConnectedMachine -ResourceGroupName "rg-hkltd-arc"

foreach ($server in $servers) {
    Write-Host "Installing Azure Monitor Agent on $($server.Name)..."
    
    if ($server.OSType -eq "Windows") {
        New-AzConnectedMachineExtension `
            -MachineName $server.Name `
            -ResourceGroupName "rg-hkltd-arc" `
            -Name "AzureMonitorWindowsAgent" `
            -Publisher "Microsoft.Azure.Monitor" `
            -ExtensionType "AzureMonitorWindowsAgent" `
            -Location $server.Location
    }
    else {
        New-AzConnectedMachineExtension `
            -MachineName $server.Name `
            -ResourceGroupName "rg-hkltd-arc" `
            -Name "AzureMonitorLinuxAgent" `
            -Publisher "Microsoft.Azure.Monitor" `
            -ExtensionType "AzureMonitorLinuxAgent" `
            -Location $server.Location
    }
}
```

### Step 2: Verify Extensions

For each server, go to **Extensions** and verify:

| Extension | Status | Purpose |
|-----------|--------|---------|
| Azure Monitor Agent | Succeeded ✅ | Monitoring and logs |
| Guest Configuration | Succeeded ✅ | Policy compliance |
| SQL Server (sql1 only) | Succeeded ✅ | SQL management |

---

## Exercise 8: Explore Arc Management

### Step 1: View Server Properties

For each Arc-enabled server, explore:

1. **Overview** — Status, OS, agent version, last heartbeat
2. **Properties** — Machine details, location, tags
3. **Extensions** — Installed extensions
4. **Policies** — Policy compliance
5. **Update management** — Available updates

### Step 2: Add Tags

Tag all Arc-enabled servers:

```powershell
$servers = Get-AzConnectedMachine -ResourceGroupName "rg-hkltd-arc"

foreach ($server in $servers) {
    Update-AzConnectedMachine `
        -ResourceGroupName "rg-hkltd-arc" `
        -Name $server.Name `
        -Tag @{
            "Environment" = "Lab"
            "Company"     = "HarisKhurshidLTD"
            "Workshop"    = "AzureMigrateArc"
            "ManagedBy"   = "AzureArc"
        }
}
```

### Step 3: Run Azure Arc Health Check

```powershell
# Check all Arc-enabled servers
$servers = Get-AzConnectedMachine -ResourceGroupName "rg-hkltd-arc"

Write-Host "`n========== ARC HEALTH CHECK ==========" -ForegroundColor Cyan

foreach ($server in $servers) {
    $color = if ($server.Status -eq "Connected") { "Green" } else { "Red" }
    Write-Host "`n  Server: $($server.Name)" -ForegroundColor Yellow
    Write-Host "    Status:     $($server.Status)" -ForegroundColor $color
    Write-Host "    OS:         $($server.OSType) $($server.OSName)"
    Write-Host "    Agent:      $($server.AgentVersion)"
    Write-Host "    Last Seen:  $($server.LastStatusChange)"
    
    # Check extensions
    $extensions = Get-AzConnectedMachineExtension -MachineName $server.Name -ResourceGroupName "rg-hkltd-arc"
    foreach ($ext in $extensions) {
        $extColor = if ($ext.ProvisioningState -eq "Succeeded") { "Green" } else { "Red" }
        Write-Host "    Extension:  $($ext.Name) — $($ext.ProvisioningState)" -ForegroundColor $extColor
    }
}

Write-Host "`n========== END ARC CHECK ==========" -ForegroundColor Cyan
```

---

## ✅ Module Complete!

You have successfully:
- [x] Registered Azure Arc resource providers
- [x] Generated onboarding scripts
- [x] Onboarded 4 Windows servers to Azure Arc
- [x] Onboarded 1 Linux server to Azure Arc
- [x] Onboarded SQL Server to Azure Arc
- [x] Applied Azure Policy to Arc-enabled resources
- [x] Deployed extensions (Azure Monitor Agent)
- [x] Explored Arc management features
- [x] Tagged and organized Arc resources

---

## 💡 Key Takeaways

1. **Azure Arc** brings Azure management to ANY infrastructure
2. You **don't need to migrate** — manage in-place
3. **Same Azure tools** work for Arc-enabled servers (Policy, Monitor, Defender)
4. **Arc-enabled SQL Server** gives Azure SQL features without migration
5. **Extensions** deploy Azure capabilities to on-prem servers
6. **At-scale onboarding** uses service principals and scripts
7. Arc + Migrate = complete hybrid strategy

---

## 🔄 Arc vs. Migrate: When to Use What?

| Scenario | Use Azure Arc | Use Azure Migrate |
|----------|:------------:|:----------------:|
| Keep workloads on-premises | ✅ | — |
| Move workloads to Azure | — | ✅ |
| Apply Azure Policy on-prem | ✅ | — |
| Right-size for Azure | — | ✅ |
| Monitor from Azure Portal | ✅ | — |
| Reduce on-prem footprint | — | ✅ |
| Hybrid management | ✅ | — |
| Both (manage now, migrate later) | ✅ | ✅ |

---

## ➡️ Next Module

Proceed to **[Module 04: Governance — Defender, Monitor, Backup](../module-04-governance/)**

---

*Azure Migrate & Arc Workshop — Haris Khurshid, MCT*
