# Module 2: Discovery & Assessment

In this module you deploy the Azure Migrate appliance, discover on-premises servers, and run an assessment to estimate Azure readiness and costs.

## Steps

### 1. Create an Azure Migrate Project

```bash
az migrate project create \
  --resource-group rg-migrate-workshop \
  --name migrate-workshop-project \
  --location eastus
```

### 2. Deploy the Azure Migrate Appliance

1. In the Azure Portal, navigate to **Azure Migrate → Servers, databases and web apps**.
2. Under **Discovery tools**, select **Azure Migrate: Discovery and assessment → Discover**.
3. Choose **Virtualize with Hyper-V** (or the hypervisor matching your lab).
4. Download the appliance OVA / VHD and deploy it on your on-premises host.
5. Complete the appliance configuration wizard and register it with the project.

### 3. Start Discovery

After the appliance is registered, discovery starts automatically and typically completes within 24 hours for small environments.

### 4. Create an Assessment

```bash
az offazure assessment create \
  --project-name migrate-workshop-project \
  --resource-group rg-migrate-workshop \
  --name assessment-01 \
  --target-location eastus \
  --sizing-criterion performance-based
```

### 5. Review Assessment Results

In the Azure Portal, open the assessment to review:

- **Azure readiness** — which servers are ready to migrate as-is
- **Monthly cost estimate** — projected compute and storage costs
- **Recommended VM SKUs** — right-sized Azure VM recommendations

## Next Module

➡️ [Module 3: Server Migration](03-server-migration.md)
