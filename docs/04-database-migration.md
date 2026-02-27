# Module 4: Database Migration

Migrate on-premises SQL Server databases to **Azure SQL Managed Instance** or **Azure SQL Database** using Azure Database Migration Service (DMS).

## Steps

### 1. Create an Azure SQL Target

```bash
# Example: Azure SQL Managed Instance
az sql mi create \
  --name sqlmi-workshop \
  --resource-group rg-migrate-workshop \
  --location eastus \
  --admin-user sqladmin \
  --admin-password "<YourSecurePassword>" \
  --subnet /subscriptions/<sub-id>/resourceGroups/rg-migrate-workshop/providers/Microsoft.Network/virtualNetworks/vnet-lab/subnets/subnet-sqlmi
```

### 2. Create a DMS Instance

```bash
az dms create \
  --name dms-workshop \
  --resource-group rg-migrate-workshop \
  --location eastus \
  --sku-name Premium_4vCores \
  --subnet /subscriptions/<sub-id>/resourceGroups/rg-migrate-workshop/providers/Microsoft.Network/virtualNetworks/vnet-lab/subnets/subnet-dms
```

### 3. Create a Migration Project

```bash
az dms project create \
  --name sql-migration-project \
  --service-name dms-workshop \
  --resource-group rg-migrate-workshop \
  --location eastus \
  --source-platform SQL \
  --target-platform SQLMI
```

### 4. Start the Migration

Use the Azure Portal **Database Migration Service → New Migration Project** wizard to:

1. Connect to the source SQL Server on `vm-sql01`.
2. Select the databases to migrate.
3. Configure the Azure SQL MI target.
4. Choose **Online migration** (minimal downtime) or **Offline migration**.
5. Start migration and monitor progress.

### 5. Cutover (Online Migration Only)

When the migration status shows **Ready to cutover**:

1. Stop new writes to the source database.
2. Click **Start cutover** in the Azure Portal.
3. Update application connection strings to point to the Azure SQL MI endpoint.

## Next Module

➡️ [Module 5: Azure Arc Onboarding](05-arc-onboarding.md)
