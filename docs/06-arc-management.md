# Module 6: Arc-enabled Management

Use **Azure Arc** to manage, govern, and monitor your connected servers at scale.

## Topics Covered

- Azure Policy for Arc-enabled servers
- Microsoft Defender for Cloud integration
- Azure Monitor & Log Analytics
- Update Management Center

## Steps

### 1. Assign Azure Policy

Apply the **Configure Log Analytics extension** built-in policy to all Arc-enabled servers:

```bash
az policy assignment create \
  --name "arc-log-analytics" \
  --display-name "Configure Log Analytics on Arc Servers" \
  --policy "2227e1f1-23dd-4c3a-85a9-7bf8b07f6a6f" \
  --scope /subscriptions/<sub-id>/resourceGroups/rg-migrate-workshop \
  --mi-user-assigned /subscriptions/<sub-id>/resourceGroups/rg-migrate-workshop/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-policy
```

### 2. Enable Microsoft Defender for Servers

```bash
az security pricing create \
  --name VirtualMachines \
  --tier standard
```

Arc-enabled servers automatically inherit Defender for Servers protection.

### 3. Enable Update Management

In the Azure Portal:

1. Navigate to **Azure Arc → Servers**.
2. Select a server → **Update Management**.
3. Enable and link to a Log Analytics workspace.
4. Schedule automatic patching under **Update schedules**.

### 4. View Insights in Azure Monitor

```bash
az monitor log-analytics workspace create \
  --resource-group rg-migrate-workshop \
  --workspace-name law-workshop \
  --location eastus
```

Link the workspace to Azure Monitor VM Insights to view CPU, memory, disk, and network metrics for all Arc-connected servers in a single dashboard.

## Workshop Complete 🎉

Congratulations — you have successfully:

- ✅ Deployed a simulated on-premises lab
- ✅ Discovered and assessed workloads with Azure Migrate
- ✅ Migrated servers and databases to Azure
- ✅ Onboarded servers to Azure Arc
- ✅ Applied governance and monitoring at scale

## Clean Up

To avoid ongoing charges, delete the resource group when you're finished:

```bash
az group delete \
  --name rg-migrate-workshop \
  --yes \
  --no-wait
```
