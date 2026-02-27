# Module 5: Azure Arc Onboarding

Connect on-premises servers (and any remaining non-migrated machines) to **Azure Arc** for unified management from the Azure Portal.

## Steps

### 1. Register the Azure Arc Resource Provider

```bash
az provider register --namespace Microsoft.HybridCompute
az provider register --namespace Microsoft.GuestConfiguration
az provider register --namespace Microsoft.HybridConnectivity
```

### 2. Generate an Onboarding Script

```bash
az connectedmachine generate-installation-script \
  --resource-group rg-migrate-workshop \
  --location eastus \
  --os windows \
  --output json | jq -r '.scriptContent' > onboard-windows.ps1
```

For Linux:

```bash
az connectedmachine generate-installation-script \
  --resource-group rg-migrate-workshop \
  --location eastus \
  --os linux \
  --output json | jq -r '.scriptContent' > onboard-linux.sh
```

### 3. Run the Script on Each Server

**Windows (PowerShell — run as Administrator):**

```powershell
.\onboard-windows.ps1
```

**Linux (Bash — run as root):**

```bash
sudo bash onboard-linux.sh
```

### 4. Verify Connected Machines

```bash
az connectedmachine list \
  --resource-group rg-migrate-workshop \
  --query "[].{Name:name, Status:status, OS:osName}" \
  --output table
```

All onboarded servers should show **Connected** status.

## Next Module

➡️ [Module 6: Arc-enabled Management](06-arc-management.md)
