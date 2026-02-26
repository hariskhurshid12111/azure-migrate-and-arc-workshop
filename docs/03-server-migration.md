# Module 3: Server Migration

Replicate on-premises VMs and cut over to Azure using **Azure Migrate: Server Migration**.

## Steps

### 1. Add the Server Migration Tool

In your Azure Migrate project, select **Azure Migrate: Server Migration → Discover** and follow the wizard to configure replication.

### 2. Enable Replication

For each VM you want to migrate:

```bash
az offazure machine show \
  --project-name migrate-workshop-project \
  --resource-group rg-migrate-workshop
```

In the Portal, select the machines discovered in Module 2, then click **Replicate**.

### 3. Monitor Replication

```bash
az migrate replication-eligibility-result list \
  --resource-group rg-migrate-workshop
```

Wait until replication health shows **Healthy** for all machines.

### 4. Run a Test Migration

Before the final cutover, run a test migration to validate connectivity:

1. Select the replicated item → **Test migration**.
2. Choose an isolated test virtual network.
3. Verify the VM boots correctly and services are accessible.
4. Click **Clean up test migration** when done.

### 5. Migrate (Cutover)

1. Select the replicated item → **Migrate**.
2. Choose **Yes** to shut down the on-premises VM before migration (minimizes data loss).
3. Click **Migrate** and wait for completion.

### 6. Verify Post-Migration

- Confirm the migrated VM is accessible via RDP/SSH.
- Validate application functionality.
- Update DNS records to point to the new Azure private/public IP.

## Next Module

➡️ [Module 4: Database Migration](04-database-migration.md)
