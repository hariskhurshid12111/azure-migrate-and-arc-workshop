# 🎯 Microsoft Exam Objectives Mapping

This document maps each workshop module to specific Microsoft certification exam objectives.

---

## Exams Covered

| Exam | Name | Level |
|------|------|-------|
| **AZ-104** | Microsoft Azure Administrator | Associate |
| **AZ-305** | Designing Microsoft Azure Infrastructure Solutions | Expert |
| **AZ-800** | Administering Windows Server Hybrid Core Infrastructure | Associate |
| **AZ-801** | Configuring Windows Server Hybrid Advanced Services | Associate |
| **SC-200** | Microsoft Security Operations Analyst | Associate |

---

## Module-to-Exam Matrix

| Module | AZ-104 | AZ-305 | AZ-800 | AZ-801 | SC-200 |
|--------|--------|--------|--------|--------|--------|
| Module 00: Deploy Environment | ✅ | ✅ | — | — | — |
| Module 01: Explore On-Prem | — | — | ✅ | ✅ | — |
| Module 02: Azure Migrate | ✅ | ✅ | — | ✅ | — |
| Module 03: Azure Arc | ✅ | ✅ | ✅ | ✅ | ✅ |
| Module 04: Governance | ✅ | ✅ | — | ✅ | ✅ |

---

## AZ-104: Microsoft Azure Administrator

### Skills Measured & Workshop Coverage

| Objective Area | Specific Skill | Module |
|---------------|---------------|--------|
| **Manage Azure identities and governance** | Manage Azure AD objects | Module 03, 04 |
| | Manage role-based access control (RBAC) | Module 04 |
| | Manage subscriptions and governance | Module 04 |
| **Implement and manage storage** | Configure Azure Storage accounts | Module 02 |
| **Deploy and manage Azure compute resources** | Deploy and manage VMs | Module 00, 02 |
| | Configure VMs for high availability | Module 02 |
| | Automate deployment using ARM templates | Module 00 |
| **Implement and manage virtual networking** | Configure virtual networks | Module 00 |
| | Configure NSGs | Module 00 |
| | Configure name resolution | Module 01 |
| **Monitor and maintain Azure resources** | Configure monitoring | Module 04 |
| | Implement backup and recovery | Module 04 |
| | Configure Azure Monitor and alerts | Module 04 |

---

## AZ-305: Designing Microsoft Azure Infrastructure Solutions

### Skills Measured & Workshop Coverage

| Objective Area | Specific Skill | Module |
|---------------|---------------|--------|
| **Design identity, governance, and monitoring** | Design governance solutions | Module 04 |
| | Design monitoring solutions | Module 04 |
| | Design authentication and authorization | Module 03 |
| **Design data storage solutions** | Design data storage for relational data | Module 02 |
| | Design data migration solutions | Module 02 |
| **Design business continuity solutions** | Design backup solutions | Module 04 |
| | Design high availability solutions | Module 02 |
| **Design infrastructure solutions** | Design compute solutions | Module 02 |
| | Design migration solutions | Module 02 |
| | Design network solutions | Module 00, 02 |
| | Design hybrid connectivity | Module 03 |

---

## AZ-800: Administering Windows Server Hybrid Core Infrastructure

### Skills Measured & Workshop Coverage

| Objective Area | Specific Skill | Module |
|---------------|---------------|--------|
| **Deploy and manage AD DS** | Deploy and manage AD DS domain controllers | Module 01 |
| | Manage AD DS objects (users, groups, OUs) | Module 01 |
| | Configure Group Policy | Module 01 |
| **Manage Windows Servers** | Manage Windows Server using remote admin tools | Module 01 |
| | Configure and manage Hyper-V | Module 01 |
| | Configure Hyper-V networking | Module 01 |
| **Manage VMs and containers** | Manage Hyper-V VMs | Module 01 |
| | Create and configure VMs | Module 01 |
| **Implement and manage hybrid networking** | Implement hybrid network connectivity | Module 03 |
| **Manage storage and file services** | Configure Windows Server storage | Module 01 |
| **Deploy and manage DNS and DHCP** | Deploy and manage DNS | Module 01 |
| | Deploy and manage DHCP | Module 01 |

---

## AZ-801: Configuring Windows Server Hybrid Advanced Services

### Skills Measured & Workshop Coverage

| Objective Area | Specific Skill | Module |
|---------------|---------------|--------|
| **Secure Windows Server** | Configure Windows Server security | Module 04 |
| | Manage security with Microsoft Defender | Module 04 |
| **Implement high availability** | Implement high availability in Windows Server | Module 02 |
| **Implement disaster recovery** | Manage backup and recovery | Module 04 |
| | Implement disaster recovery using Azure Site Recovery | Module 02 |
| **Migrate servers and workloads** | Migrate on-premises workloads using Azure Migrate | Module 02 |
| | Assess migration readiness | Module 02 |
| | Migrate Windows Server workloads | Module 02 |
| | Migrate IIS workloads | Module 02 |
| | Migrate SQL Server workloads | Module 02 |
| **Monitor and troubleshoot** | Monitor Windows Server using Azure services | Module 04 |
| | Monitor using Azure Monitor and Log Analytics | Module 04 |
| **Implement hybrid scenarios** | Implement Azure Arc-enabled servers | Module 03 |
| | Manage Azure Arc-enabled servers | Module 03 |
| | Implement Azure Arc-enabled SQL Server | Module 03 |

---

## SC-200: Microsoft Security Operations Analyst

### Skills Measured & Workshop Coverage

| Objective Area | Specific Skill | Module |
|---------------|---------------|--------|
| **Mitigate threats using Microsoft Defender** | Manage the Defender for Cloud environment | Module 04 |
| | Configure Defender for Servers | Module 04 |
| | Configure Defender for SQL | Module 04 |
| | Review and respond to security recommendations | Module 04 |
| **Mitigate threats using Microsoft Sentinel** | Configure Azure Sentinel workspace | Module 04 |
| | Connect data sources to Sentinel | Module 04 |
| **Configure security for Azure Arc** | Implement security for Arc-enabled servers | Module 03 |
| | Apply Azure Policy for compliance | Module 03, 04 |
| | Monitor Arc-enabled resources | Module 03, 04 |

---

## Study Tips

### Before the Workshop
1. Review the exam objectives on [Microsoft Learn](https://learn.microsoft.com/en-us/certifications/)
2. Note which areas you need the most practice
3. Focus on the modules that map to your target exam

### During the Workshop
1. Follow each module step-by-step
2. Take screenshots of key configurations
3. Note the Azure services used and how they connect
4. Practice the PowerShell commands — exams test CLI knowledge

### After the Workshop
1. Review your notes against the exam objectives above
2. Try the exercises again without following the guide
3. Explore additional scenarios not covered in the modules
4. Use [Microsoft Learn](https://learn.microsoft.com/) for deeper study on weak areas

---

## Certification Paths

```
                    ┌───────────┐
                    │  AZ-900   │  (Fundamentals - recommended prerequisite)
                    │  Azure    │
                    │  Fund.    │
                    └─────┬─────┘
                          │
            ┌─────────────┼─────────────┐
            ▼             ▼             ▼
      ┌───────────┐ ┌───────────┐ ┌───────────┐
      │  AZ-104   │ │  AZ-800   │ │  SC-200   │
      │  Azure    │ │  Win Svr  │ │  Security │
      │  Admin    │ │  Hybrid   │ │  Ops      │
      └─────┬─────┘ └─────┬─────┘ └───────────┘
            │             │
            ▼             ▼
      ┌───────────┐ ┌───────────┐
      │  AZ-305   │ │  AZ-801   │
      │  Azure    │ │  Win Svr  │
      │  Architect│ │  Advanced │
      └───────────┘ └───────────┘
```

---

*Maintained by Haris Khurshid, MCT — [GitHub](https://github.com/hariskhurshid12111)*
