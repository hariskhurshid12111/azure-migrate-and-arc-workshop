# 🛡️ Module 04: Governance — Defender, Monitor, Backup

## Overview

In this module, you will implement **Azure governance and security** for the HarisKhurshidLTD hybrid environment. You will enable Microsoft Defender for Cloud, configure Azure Monitor with Log Analytics, apply Azure Policy for compliance, set up Azure Backup, and explore Microsoft Sentinel for security operations.

---

## ⏱️ Estimated Time: 90-120 minutes

---

## 🎯 Objectives

After completing this module, you will be able to:

- Enable Microsoft Defender for Cloud for hybrid servers
- Configure Defender for SQL on Arc-enabled SQL Server
- Create a Log Analytics workspace
- Configure Data Collection Rules for Azure Monitor
- Deploy Azure Monitor Agent to Arc-enabled servers
- Assign and enforce Azure Policy for compliance
- Remediate non-compliant resources
- Configure Azure Backup for Arc-enabled servers
- Explore Azure Update Management
- Set up Microsoft Sentinel for security monitoring
- Review and act on security recommendations

---

## 📋 Prerequisites

- Completed [Module 00](../module-00-deploy-environment/), [Module 01](../module-01-explore-onprem/), [Module 02](../module-02-azure-migrate/), and [Module 03](../module-03-azure-arc/)
- All 5 servers onboarded to Azure Arc (from Module 03)
- Azure subscription with Contributor access
- RDP connection to the Hyper-V host

---

## 🔑 Credentials Reference

| Service | Username | Password |
|---------|----------|----------|
| Domain Admin | HARISKLTD\Administrator | P@ssw0rd123! |
| SQL SA | sa | P@ssw0rd123! |

---

## Exercise 1: Enable Microsoft Defender for Cloud

### Step 1: Navigate to Defender for Cloud

1. Open [Azure Portal](https://portal.azure.com)
2. Search for **Microsoft Defender for Cloud**
3. Click **Microsoft Defender for Cloud**

### Step 2: Review Security Posture

1. Click **Overview** to see your current secure score
2. Note the score — we'll improve it in this module

### Step 3: Enable Defender Plans

1. Click **Environment settings**
2. Select your subscription
3. Enable the following plans:

| Plan | Status | Purpose |
|------|--------|---------|
| **Defender for Servers** | ON ✅ | Protect Windows & Linux servers |
| **Defender for SQL** | ON ✅ | Protect SQL Server instances |
| **Defender for Storage** | Optional | Protect storage accounts |
| **Defender for Key Vault** | Optional | Protect secrets |

4. Click **Save**

### Step 4: Verify Arc Servers in Defender

1. Go to **Defender for Cloud** → **Inventory**
2. Filter by resource type: **Arc-enabled servers**
3. You should see all 5 Arc-enabled servers:

| Server | Defender Status |
|--------|----------------|
| hariskhurshidltd-dc | Protected ✅ |
| hariskhurshidltdweb1 | Protected ✅ |
| hariskhurshidltdweb2 | Protected ✅ |
| hariskhurshidltdsql1 | Protected ✅ |
| hariskhurshidltdlinux1 | Protected ✅ |

### Step 5: Review Security Recommendations

1. Click **Recommendations**
2. Review the top recommendations for your Arc-enabled servers
3. Common recommendations:

| Recommendation | Severity | Action |
|---------------|----------|--------|
| Install endpoint protection | High | Install Defender for Endpoint |
| Enable vulnerability assessment | High | Enable Qualys or built-in scanner |
| Apply system updates | Medium | Use Update Management |
| Encrypt disks | Medium | Enable disk encryption |
| Restrict management ports | High | Configure NSG/firewall |

---

## Exercise 2: Configure Defender for SQL

### Step 1: Enable SQL Vulnerability Assessment

1. Go to **Defender for Cloud** → **Environment settings**
2. Select your subscription → **Defender plans**
3. Ensure **Defender for SQL** is **ON**
4. Click **Settings** next to Defender for SQL

### Step 2: Configure SQL Advanced Threat Protection

1. Go to **Azure Arc** → **SQL Server instances**
2. Click on the SQL instance from `hariskhurshidltdsql1`
3. Click **Security** (or **Microsoft Defender for SQL**)
4. Enable:
   - ✅ SQL Vulnerability Assessment
   - ✅ SQL Advanced Threat Protection

### Step 3: Run a Vulnerability Scan

1. In the SQL Server Arc resource → **Vulnerability Assessment**
2. Click **Scan** to run an initial assessment
3. Review findings:

| Finding | Severity | Description |
|---------|----------|-------------|
| SA account enabled | High | Disable or rename SA |
| Weak passwords | High | Enforce password policy |
| Guest account | Medium | Disable guest access |
| Audit not enabled | Medium | Enable SQL audit |

### Step 4: Review SQL Security Alerts

1. Go to **Defender for Cloud** → **Security alerts**
2. Filter by resource: SQL Server
3. Review any alerts for suspicious SQL activity

---

## Exercise 3: Configure Azure Monitor

### Step 1: Create Log Analytics Workspace

1. Search for **Log Analytics workspaces** in Azure Portal
2. Click **Create**
3. Fill in:

| Setting | Value |
|---------|-------|
| Subscription | Your subscription |
| Resource Group | `rg-hkltd-arc` |
| Name | `law-hkltd-workshop` |
| Region | East US (same as Arc resources) |

4. Click **Review + Create** → **Create**

### Step 2: Create Data Collection Rule

1. Search for **Monitor** → Click **Azure Monitor**
2. Click **Data Collection Rules** → **Create**
3. Fill in:

| Setting | Value |
|---------|-------|
| Rule name | `dcr-hkltd-servers` |
| Subscription | Your subscription |
| Resource Group | `rg-hkltd-arc` |
| Region | East US |
| Platform type | All |

4. Click **Next: Resources**
5. Click **Add resources** → Select all 5 Arc-enabled servers
6. Click **Next: Collect and deliver**

### Step 3: Add Data Sources

Add the following data sources:

**Windows Event Logs:**
| Log | Level |
|-----|-------|
| Application | Critical, Error, Warning |
| System | Critical, Error, Warning |
| Security | Audit Success, Audit Failure |

**Performance Counters:**
| Counter | Interval |
|---------|----------|
| Processor - % Processor Time | 60 seconds |
| Memory - Available MBytes | 60 seconds |
| LogicalDisk - % Free Space | 300 seconds |
| Network - Bytes Total/sec | 60 seconds |

**Linux Syslog:**
| Facility | Level |
|----------|-------|
| auth | Warning and above |
| syslog | Warning and above |
| daemon | Error and above |

### Step 4: Configure Destination

| Setting | Value |
|---------|-------|
| Destination type | Azure Monitor Logs |
| Workspace | `law-hkltd-workshop` |

Click **Review + Create** → **Create**

### Step 5: Verify Data Collection

Wait 10-15 minutes, then:

1. Go to **Log Analytics workspace** → `law-hkltd-workshop`
2. Click **Logs**
3. Run these queries:

```kusto
// Check heartbeat from all servers
Heartbeat
| summarize LastHeartbeat = max(TimeGenerated) by Computer
| order by LastHeartbeat desc

// Check Windows events
Event
| where TimeGenerated > ago(1h)
| summarize count() by Computer, EventLog
| order by count_ desc

// Check performance data
Perf
| where TimeGenerated > ago(1h)
| summarize avg(CounterValue) by Computer, CounterName
| order by Computer asc
```

---

## Exercise 4: Create Monitoring Dashboards

### Step 1: Create Azure Dashboard

1. Go to **Azure Portal** → **Dashboard** → **New dashboard**
2. Name it: `HarisKhurshidLTD Lab Monitor`

### Step 2: Add Tiles

Add these tiles from the tile gallery:

| Tile | Source | Purpose |
|------|--------|---------|
| **Arc Server Map** | Azure Arc | Visual server inventory |
| **Defender Secure Score** | Defender for Cloud | Security posture |
| **Policy Compliance** | Azure Policy | Governance status |
| **Log Query: Heartbeat** | Log Analytics | Server health |
| **Log Query: CPU** | Log Analytics | Performance |

### Step 3: Pin Log Analytics Queries

1. Go to Log Analytics → Logs
2. Run this query:

```kusto
// Server Health Dashboard
Heartbeat
| summarize LastHeartbeat = max(TimeGenerated) by Computer, OSType, Category
| extend Status = iff(LastHeartbeat > ago(5m), "Healthy", "Unhealthy")
| project Computer, OSType, Status, LastHeartbeat
| order by Status asc, Computer asc
```

3. Click **Pin to dashboard** → Select your dashboard

### Step 4: Create Alert Rules

1. In Log Analytics → **Alerts** → **New alert rule**
2. Create these alerts:

**Alert 1: Server Heartbeat Lost**
```kusto
Heartbeat
| summarize LastHeartbeat = max(TimeGenerated) by Computer
| where LastHeartbeat < ago(10m)
```
- Severity: 1 (Error)
- Frequency: Every 5 minutes

**Alert 2: High CPU Usage**
```kusto
Perf
| where CounterName == "% Processor Time"
| where CounterValue > 90
| summarize AvgCPU = avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
| where AvgCPU > 90
```
- Severity: 2 (Warning)
- Frequency: Every 15 minutes

---

## Exercise 5: Azure Policy for Compliance

### Step 1: Assign Built-in Policy Initiative

1. Go to **Azure Policy** → **Assignments** → **Assign initiative**
2. Search for and assign:

**Initiative:** "Enable Azure Monitor for Hybrid VMs with AMA"

| Setting | Value |
|---------|-------|
| Scope | Resource Group: `rg-hkltd-arc` |
| Log Analytics workspace | `law-hkltd-workshop` |

### Step 2: Assign Individual Policies

Assign these additional policies to `rg-hkltd-arc`:

| Policy | Effect | Purpose |
|--------|--------|---------|
| Require a tag and its value on resources | Deny | Enforce tagging |
| Inherit a tag from resource group | Modify | Auto-tag resources |
| Configure Arc machines to use Azure Monitor | DeployIfNotExists | Auto-deploy agent |
| Audit machines with insecure password settings | AuditIfNotExists | Password compliance |
| Windows machines should have Log Analytics agent | AuditIfNotExists | Monitoring compliance |

### Step 3: Create Custom Policy (Optional)

Create a custom policy to audit Arc servers without specific extensions:

```json
{
  "mode": "Indexed",
  "policyRule": {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.HybridCompute/machines"
        },
        {
          "field": "tags['Environment']",
          "exists": "false"
        }
      ]
    },
    "then": {
      "effect": "audit"
    }
  },
  "parameters": {}
}
```

### Step 4: Review Compliance Dashboard

1. Go to **Azure Policy** → **Compliance**
2. Filter by scope: `rg-hkltd-arc`
3. Review:

| Metric | Description |
|--------|-------------|
| Overall compliance % | Percentage of compliant resources |
| Non-compliant resources | Resources that need remediation |
| Non-compliant policies | Policies with violations |

### Step 5: Create Remediation Tasks

For each non-compliant `DeployIfNotExists` policy:

1. Click the policy → **Create remediation task**
2. Select scope and resources
3. Click **Remediate**
4. Monitor remediation progress

---

## Exercise 6: Azure Backup for Arc Servers

### Step 1: Create Recovery Services Vault

1. Search for **Recovery Services vaults** → **Create**
2. Fill in:

| Setting | Value |
|---------|-------|
| Subscription | Your subscription |
| Resource Group | `rg-hkltd-arc` |
| Vault name | `rsv-hkltd-backup` |
| Region | East US |

3. Click **Review + Create** → **Create**

### Step 2: Configure Backup Policy

1. Open the vault → **Backup policies** → **Add**
2. Create a policy:

| Setting | Value |
|---------|-------|
| Policy name | `policy-hkltd-daily` |
| Backup frequency | Daily at 2:00 AM |
| Instant restore retention | 2 days |
| Daily retention | 30 days |
| Weekly retention | 4 weeks (Sunday) |
| Monthly retention | 12 months (First Sunday) |

### Step 3: Enable Backup for Arc Servers

1. In the vault → **Backup** → **Get started**
2. Select:
   - **Where is your workload running?** → On-premises
   - **What do you want to back up?** → Files and folders
3. Download and install the **MARS agent** on each server

Or for VM-level backup via Arc:

1. Go to **Azure Arc** → **Servers** → Select a server
2. Click **Backup** (if available)
3. Select the Recovery Services vault
4. Select the backup policy
5. Click **Enable backup**

### Step 4: Trigger a Test Backup

1. On the server, open **Microsoft Azure Backup**
2. Click **Back Up Now**
3. Select data to back up
4. Click **Back Up**

### Step 5: Verify Backup

1. In the Recovery Services vault → **Backup items**
2. Verify each server shows:

| Server | Backup Status | Last Backup |
|--------|--------------|-------------|
| hariskhurshidltd-dc | Completed ✅ | (date) |
| hariskhurshidltdweb1 | Completed ✅ | (date) |
| hariskhurshidltdsql1 | Completed ✅ | (date) |

---

## Exercise 7: Azure Update Management

### Step 1: Navigate to Update Management

1. Go to **Azure Arc** → **Servers** → Select any server
2. Click **Updates** (under Operations)

### Step 2: Assess Updates

1. Click **Check for updates** or **Assess now**
2. Wait for assessment to complete
3. Review available updates:

| Category | Count |
|----------|-------|
| Critical | ? |
| Security | ? |
| Update Rollups | ? |
| Other | ? |

### Step 3: Create Update Deployment

1. Click **Schedule updates**
2. Configure:

| Setting | Value |
|---------|-------|
| Name | `hkltd-monthly-patches` |
| Machines | All Arc-enabled servers |
| Update classifications | Critical, Security |
| Schedule | Monthly, Second Tuesday, 2:00 AM |
| Maintenance window | 3 hours |
| Reboot | If required |

3. Click **Create**

### Step 4: Monitor Update Compliance

1. Go to **Azure Arc** → **Servers**
2. Check the **Updates** column for each server
3. Review the update compliance dashboard

---

## Exercise 8: Microsoft Sentinel (Optional)

### Step 1: Enable Microsoft Sentinel

1. Search for **Microsoft Sentinel** → Click **Create**
2. Select your Log Analytics workspace: `law-hkltd-workshop`
3. Click **Add**

### Step 2: Connect Data Sources

1. In Sentinel → **Data connectors**
2. Enable these connectors:

| Connector | Purpose |
|-----------|---------|
| **Windows Security Events via AMA** | Security event logs |
| **Syslog** | Linux security logs |
| **Microsoft Defender for Cloud** | Security alerts |
| **Azure Activity** | Azure management plane |

### Step 3: Enable Analytics Rules

1. Go to **Analytics** → **Rule templates**
2. Enable these built-in rules:

| Rule | Severity |
|------|----------|
| Successful logon from IP not seen in last 14 days | Medium |
| Multiple failed logon attempts | Medium |
| New user account created | Low |
| Account added to admin group | High |
| Suspicious PowerShell commands | High |

### Step 4: Create a Custom Analytics Rule

1. Click **Create** → **Scheduled query rule**
2. Configure:

| Setting | Value |
|---------|-------|
| Name | `HKLTD - Failed RDP Brute Force` |
| Severity | High |
| MITRE ATT&CK | Credential Access |

Query:
```kusto
SecurityEvent
| where EventID == 4625
| where TimeGenerated > ago(1h)
| summarize FailedAttempts = count() by TargetAccount, Computer, IpAddress = tostring(EventData)
| where FailedAttempts > 10
| project TimeGenerated = now(), TargetAccount, Computer, IpAddress, FailedAttempts
```

### Step 5: Explore Sentinel Dashboard

1. **Overview** — Incidents, alerts, data volume
2. **Incidents** — Active security incidents
3. **Workbooks** — Visual security reports
4. **Hunting** — Proactive threat hunting queries

---

## Exercise 9: Security Review and Hardening

### Step 1: Review Secure Score

1. Go to **Defender for Cloud** → **Secure score**
2. Compare your current score with the initial score from Exercise 1
3. Review the score breakdown:

| Category | Max Score | Your Score |
|----------|-----------|------------|
| Identity and access | | |
| Protect endpoints | | |
| Apply system updates | | |
| Encrypt data | | |
| Restrict access | | |

### Step 2: Implement Top Recommendations

Work through the top 5 recommendations to improve your score:

1. Click on each recommendation
2. Follow the remediation steps
3. Re-check your score after remediation

### Step 3: Generate Compliance Report

1. Go to **Defender for Cloud** → **Regulatory compliance**
2. Review compliance against:
   - Azure Security Benchmark
   - ISO 27001 (if available)
   - NIST SP 800-53
3. Export the compliance report for documentation

---

## Exercise 10: Final Governance Dashboard

### Step 1: Create Summary Dashboard

Create a final dashboard tile summary:

```
┌─────────────────────────────────────────────────────────┐
│           HarisKhurshidLTD Governance Dashboard          │
├─────────────────┬───────────────────┬───────────────────┤
│  Defender Score  │  Policy Compliance │  Backup Status   │
│     75/100      │       85%          │   All Protected   │
├─────────────────┼───────────────────┼───────────────────┤
│  Arc Servers     │  Sentinel Alerts   │  Update Status   │
│    5 Connected   │    2 Active        │  3 Pending       │
├─────────────────┴───────────────────┴───────────────────┤
│              Log Analytics: law-hkltd-workshop            │
│              Data Ingestion: ~500 MB/day                  │
│              Retention: 30 days                           │
└─────────────────────────────────────────────────────────┘
```

### Step 2: Document Governance Posture

| Area | Tool | Status | Notes |
|------|------|--------|-------|
| Security | Microsoft Defender | Enabled | All plans active |
| Monitoring | Azure Monitor + Log Analytics | Active | DCR configured |
| Compliance | Azure Policy | Enforced | Initiatives assigned |
| Backup | Recovery Services Vault | Protected | Daily backups |
| Updates | Update Management | Scheduled | Monthly patches |
| SIEM | Microsoft Sentinel | Active | Analytics rules enabled |
| SQL Security | Defender for SQL | Active | VA + ATP enabled |

---

## ✅ Module Complete!

You have successfully:
- [x] Enabled Microsoft Defender for Cloud
- [x] Configured Defender for SQL
- [x] Created a Log Analytics workspace
- [x] Set up Data Collection Rules
- [x] Created monitoring dashboards and alerts
- [x] Assigned and enforced Azure Policy
- [x] Remediated non-compliant resources
- [x] Configured Azure Backup
- [x] Set up Update Management
- [x] Explored Microsoft Sentinel
- [x] Reviewed and improved security posture
- [x] Created governance documentation

---

## 💡 Key Takeaways

1. **Microsoft Defender for Cloud** provides security posture management across hybrid environments
2. **Azure Monitor** with Log Analytics gives unified monitoring for Azure AND on-prem
3. **Azure Policy** enforces governance at scale — even for Arc-enabled resources
4. **Azure Backup** protects on-prem servers through the MARS agent or Arc integration
5. **Microsoft Sentinel** provides SIEM capabilities for security operations
6. **Governance is continuous** — not a one-time setup
7. All these tools work with **Azure Arc** — no migration needed

---

## 🎓 Workshop Complete!

Congratulations! You have completed all 5 modules of the **Azure Migrate & Arc Workshop**:

| Module | Title | Status |
|--------|-------|--------|
| [Module 00](../module-00-deploy-environment/) | Deploy Lab Environment | ✅ Complete |
| [Module 01](../module-01-explore-onprem/) | Explore On-Premises | ✅ Complete |
| [Module 02](../module-02-azure-migrate/) | Azure Migrate | ✅ Complete |
| [Module 03](../module-03-azure-arc/) | Azure Arc | ✅ Complete |
| [Module 04](../module-04-governance/) | Governance | ✅ Complete |

### What You've Learned:
- Deployed a complete on-premises simulation in Azure
- Explored enterprise workloads (AD, IIS, SQL, Linux)
- Used Azure Migrate for discovery, assessment, and migration
- Onboarded servers to Azure Arc for hybrid management
- Implemented governance with Defender, Monitor, Policy, Backup, and Sentinel

### Next Steps:
- Review the [Exam Mapping](../../docs/exam-mapping.md) for certification study
- Try the exercises again without following the guide
- Extend the lab with additional scenarios
- Share this workshop with colleagues!

---

## 🧹 Clean Up Resources

When you're done with the lab, clean up to avoid charges:

```powershell
# Delete all resource groups created during the workshop
Remove-AzResourceGroup -Name "rg-hkltd-workshop" -Force -AsJob
Remove-AzResourceGroup -Name "rg-hkltd-arc" -Force -AsJob
Remove-AzResourceGroup -Name "rg-hkltd-migrated" -Force -AsJob

# Verify deletion
Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like "*hkltd*" }
```

> ⚠️ **Warning:** This will permanently delete ALL lab resources including VMs, backups, and monitoring data!

---

*Azure Migrate & Arc Workshop — Haris Khurshid, MCT — [GitHub](https://github.com/hariskhurshid12111)*
