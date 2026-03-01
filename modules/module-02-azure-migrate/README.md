# 🔄 Module 02: Azure Migrate — Discover, Assess, Migrate

## Overview

In this module, you will use **Azure Migrate** to discover, assess, and migrate the on-premises workloads of HarisKhurshidLTD to Azure. You will work with the Azure Migrate appliance, create assessments, and perform test migrations.

---

## ⏱️ Estimated Time: 90-120 minutes

---

## 🎯 Objectives

After completing this module, you will be able to:

- Create an Azure Migrate project
- Deploy and configure the Azure Migrate appliance
- Discover on-premises servers and workloads
- Create Azure VM assessments
- Create Azure SQL assessments
- Configure and start server replication
- Perform a test migration
- Complete a full migration
- Clean up test migration resources

---

## 📋 Prerequisites

- Completed [Module 00](../module-00-deploy-environment/) and [Module 01](../module-01-explore-onprem/)
- All 5 nested VMs running
- Azure subscription with Contributor access
- RDP connection to the Hyper-V host

---

## 🔑 Credentials Reference

| Service | Username | Password |
|---------|----------|----------|
| Domain Admin | HARISKLTD\Administrator | P@ssw0rd123! |
| SQL SA | sa | P@ssw0rd123! |
| Hyper-V Host | localuser | *(set during deployment)* |

---

## Exercise 1: Create Azure Migrate Project

### Step 1: Navigate to Azure Migrate

1. Open [Azure Portal](https://portal.azure.com)
2. Search for **Azure Migrate** in the top search bar
3. Click **Azure Migrate**

### Step 2: Create a New Project

1. Click **Servers, databases and web apps**
2. Click **Create project**
3. Fill in:

| Setting | Value |
|---------|-------|
| Subscription | Your subscription |
| Resource Group | `rg-hkltd-workshop` (same as lab) |
| Project Name | `hkltd-migrate-project` |
| Geography | United States (or your nearest) |

4. Click **Create**

### Step 3: Verify Project Created

You should see the Azure Migrate dashboard with sections:
- Discovery
- Assessment
- Migration

---

## Exercise 2: Deploy Azure Migrate Appliance

### Step 1: Download the Appliance

1. In Azure Migrate → **Servers, databases and web apps**
2. Under **Discovery**, click **Discover**
3. Select:
   - **Are your servers virtualized?** → Yes, with Hyper-V
   - **Target region** → Your region
   - **Name your appliance** → `hkltd-appliance`
4. Click **Generate key** — **copy and save this key!**
5. Download the **.VHD** appliance file

### Step 2: Deploy Appliance in Hyper-V

1. RDP to the Hyper-V host
2. Copy the downloaded VHD to `F:\VirtualMachines\`
3. Open **Hyper-V Manager**
4. Click **Import Virtual Machine**
5. Browse to the appliance VHD
6. Assign it to `InternalNATSwitch`
7. Start the appliance VM

### Step 3: Configure the Appliance

1. Connect to the appliance VM
2. Open the **Appliance Configuration Manager** (launches automatically)
3. Accept the license terms
4. Set up prerequisites — verify all checks pass:
   - ✅ Internet connectivity
   - ✅ Time sync
   - ✅ Appliance services running
5. **Register with Azure Migrate** using the key you copied
6. Login with your Azure credentials

### Step 4: Add Discovery Sources

1. In the appliance configuration, click **Add credentials**
2. Add Hyper-V host credentials:
   - Friendly name: `HyperV-Host`
   - Username: `localuser`
   - Password: *(your deployment password)*
3. Click **Add discovery source**
4. Select **Hyper-V host**
5. Enter: IP of the Hyper-V host or `localhost`
6. Select the credential you just added

### Step 5: Start Discovery

1. Click **Start discovery**
2. Wait for discovery to complete (~5-15 minutes)
3. Verify all 5 VMs are discovered:
   - hariskhurshidltd-dc
   - hariskhurshidltdweb1
   - hariskhurshidltdweb2
   - hariskhurshidltdsql1
   - hariskhurshidltdlinux1

---

## Exercise 3: Create Azure VM Assessment

### Step 1: Navigate to Assessment

1. Go to **Azure Migrate** in the portal
2. Click **Servers, databases and web apps**
3. Under **Assessment tools**, click **Assess** → **Azure VM**

### Step 2: Configure Assessment

| Setting | Value |
|---------|-------|
| Assessment name | `hkltd-vm-assessment` |
| Discovery source | Azure Migrate appliance |
| Target location | East US (or your region) |
| Storage type | Premium managed disks |
| Reserved instances | No |
| Sizing criteria | As on-premises |
| VM series | Dsv3, Dsv5 |
| Comfort factor | 1.3 |
| Pricing | Pay as you go |

### Step 3: Select Servers

Select all 5 discovered VMs:
- [x] hariskhurshidltd-dc
- [x] hariskhurshidltdweb1
- [x] hariskhurshidltdweb2
- [x] hariskhurshidltdsql1
- [x] hariskhurshidltdlinux1

### Step 4: Create Assessment

1. Click **Create assessment**
2. Wait for assessment to calculate (~5-10 minutes)

### Step 5: Review Assessment Results

1. Click on the assessment name to view results
2. Review:

| Item | What to Check |
|------|--------------|
| **Azure readiness** | How many VMs are ready for Azure? |
| **Monthly cost estimate** | What's the estimated Azure cost? |
| **VM sizing** | What Azure VM sizes are recommended? |
| **Storage sizing** | What disk types are recommended? |
| **Confidence rating** | How confident is the assessment? |

3. Click on each VM to see detailed recommendations:
   - Recommended Azure VM size
   - Compute cost
   - Storage cost
   - Readiness issues (if any)

---

## Exercise 4: Create Azure SQL Assessment

### Step 1: Start SQL Assessment

1. In Azure Migrate, click **Assess** → **Azure SQL**
2. Fill in:

| Setting | Value |
|---------|-------|
| Assessment name | `hkltd-sql-assessment` |
| Target | Azure SQL Database / Azure SQL MI |
| Discovery source | Azure Migrate appliance |

### Step 2: Select SQL Instances

Select:
- [x] hariskhurshidltdsql1 — SQL Server 2019

### Step 3: Review SQL Assessment

After calculation, review:

| Item | What to Check |
|------|--------------|
| **Azure SQL readiness** | Is the SQL instance ready? |
| **Target recommendation** | Azure SQL DB, SQL MI, or SQL on VM? |
| **Monthly cost estimate** | Estimated cost |
| **Migration issues** | Any blocking issues? |
| **Feature compatibility** | Unsupported features? |

---

## Exercise 5: Configure Replication

### Step 1: Start Replication

1. In Azure Migrate → **Migration tools**
2. Click **Replicate**
3. Select:
   - **Are your machines virtualized?** → Yes, with Hyper-V
   - **Appliance** → hkltd-appliance

### Step 2: Select VMs to Replicate

Start with the web servers (lower risk):
- [x] hariskhurshidltdweb1
- [x] hariskhurshidltdweb2

### Step 3: Configure Target Settings

| Setting | Value |
|---------|-------|
| Subscription | Your subscription |
| Resource Group | `rg-hkltd-migrated` (create new) |
| VNet | Create or select a target VNet |
| Subnet | default |
| Storage Account | Create for replication cache |

### Step 4: Configure VM Settings

For each VM:

| Setting | Value |
|---------|-------|
| Azure VM Name | Keep original name |
| Azure VM Size | Standard_D2s_v3 (or assessment recommendation) |
| OS Disk | Premium SSD |
| Data Disk | Include all |

### Step 5: Start Replication

1. Click **Replicate**
2. Monitor replication status in Azure Migrate
3. Wait for **initial replication** to complete
   - Status: Replicating → Protected

### Step 6: Monitor Replication Health

1. Go to **Azure Migrate** → **Replicating machines**
2. Check each VM's status:

| Status | Meaning |
|--------|---------|
| Initial replication | First sync in progress |
| Protected | Ready for migration |
| Replication health: Healthy | All good |
| Replication health: Critical | Check and fix issues |

---

## Exercise 6: Test Migration

### Step 1: Select VM for Test Migration

1. In **Replicating machines**, click on `hariskhurshidltdweb1`
2. Click **Test migration**

### Step 2: Configure Test Migration

| Setting | Value |
|---------|-------|
| Virtual Network | Select a test/isolated VNet |

> ⚠️ **Important:** Use an **isolated VNet** for test migration to avoid IP conflicts with the source environment!

### Step 3: Run Test Migration

1. Click **Test migration**
2. Wait for the test VM to be created (~10-15 minutes)
3. Once complete, verify:
   - VM is running in Azure
   - OS boots successfully
   - IIS is running
   - Website is accessible

### Step 4: Clean Up Test Migration

1. After verification, go back to **Replicating machines**
2. Click on the VM → **Clean up test migration**
3. Check **"Testing is complete"**
4. Click **Clean up**

---

## Exercise 7: Perform Migration

> ⚠️ **Note:** In a real scenario, you would plan a maintenance window and follow change management procedures.

### Step 1: Pre-Migration Checklist

- [ ] Assessment reviewed and approved
- [ ] Replication is healthy (Protected status)
- [ ] Test migration completed successfully
- [ ] Target resource group created
- [ ] Target VNet configured
- [ ] DNS plan documented
- [ ] Rollback plan in place
- [ ] Stakeholders notified

### Step 2: Migrate

1. In **Replicating machines**, select the VMs
2. Click **Migrate**
3. Select:
   - **Shutdown source VMs before migration?** → Yes (recommended for data consistency)
4. Click **Migrate**

### Step 3: Monitor Migration

1. Track progress in **Azure Migrate** → **Jobs**
2. Wait for migration to complete
3. Verify:
   - VMs created in target resource group
   - VMs are running
   - Applications are functional

### Step 4: Post-Migration Steps

After successful migration:

1. **Update DNS** to point to new Azure IPs
2. **Configure NSGs** for the migrated VMs
3. **Enable Azure Backup** for migrated VMs
4. **Install Azure Monitor agent** for monitoring
5. **Decommission source VMs** (after validation period)

---

## Exercise 8: Migration Documentation

### Step 1: Record Migration Results

| VM | Source IP | Azure VM Size | Azure IP | Status | Migration Time |
|----|----------|--------------|----------|--------|---------------|
| hariskhurshidltdweb1 | 192.168.100.20 | | | | |
| hariskhurshidltdweb2 | 192.168.100.21 | | | | |

### Step 2: Lessons Learned

Document:
- What went well?
- What issues were encountered?
- How long did each phase take?
- What would you do differently?

---

## ✅ Module Complete!

You have successfully:
- [x] Created an Azure Migrate project
- [x] Deployed and configured the Azure Migrate appliance
- [x] Discovered on-premises servers
- [x] Created Azure VM assessments
- [x] Created Azure SQL assessments
- [x] Configured server replication
- [x] Performed a test migration
- [x] Completed a full migration
- [x] Documented the migration process

---

## 💡 Key Takeaways

1. **Azure Migrate** provides end-to-end migration tools
2. **Discovery** reveals what's in your environment before planning
3. **Assessments** help right-size and estimate costs
4. **Test migrations** are critical — always test before migrating
5. **Replication** provides near-zero downtime migration
6. **Post-migration** tasks (DNS, backup, monitoring) are just as important
7. The **DC and SQL Server** require special considerations — often migrated last

---

## 🔄 Migration Order Best Practice

```
Phase 1: Low Risk          Phase 2: Medium Risk       Phase 3: High Risk
├── Web Server 2 (web2)    ├── Web Server 1 (web1)    ├── SQL Server (sql1)
└── Linux Server (linux1)  └── (validate)             └── Domain Controller (dc)
                                                          (or keep on-prem)
```

---

## ➡️ Next Module

Proceed to **[Module 03: Azure Arc — Hybrid Server Management](../module-03-azure-arc/)**

---

*Azure Migrate & Arc Workshop — Haris Khurshid, MCT*
