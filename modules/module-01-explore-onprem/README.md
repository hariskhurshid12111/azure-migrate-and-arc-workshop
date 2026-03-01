# 🏢 Module 01: Explore On-Premises Environment

## Overview

In this module, you will explore the simulated on-premises environment of **HarisKhurshidLTD**. You will examine Active Directory, DNS, DHCP, IIS web servers, SQL Server, and the Linux server — understanding the current state before planning migration and hybrid management.

---

## ⏱️ Estimated Time: 60-75 minutes

---

## 🎯 Objectives

After completing this module, you will be able to:

- Navigate Active Directory Domain Services (AD DS)
- Examine DNS zones and records
- Inspect DHCP scopes and leases
- Explore IIS web server configuration
- Connect to SQL Server and examine databases
- Access and explore the Linux VM
- Document the on-premises environment for migration planning

---

## 📋 Prerequisites

- Completed [Module 00: Deploy Lab Environment](../module-00-deploy-environment/)
- All 5 nested VMs running in Hyper-V
- RDP connection to the Hyper-V host

---

## 🔑 Credentials Reference

| Service | Username | Password |
|---------|----------|----------|
| Domain Admin | HARISKLTD\Administrator | P@ssw0rd123! |
| SQL SA | sa | P@ssw0rd123! |
| SQL Web User | webuser | WebP@ss123! |

---

## Exercise 1: Explore Active Directory

### Step 1: Connect to the Domain Controller

1. Open **Hyper-V Manager** on the host
2. Right-click `hariskhurshidltd-dc` → **Connect**
3. Login: `HARISKLTD\Administrator` / `P@ssw0rd123!`

### Step 2: Open Active Directory Users and Computers

1. Click **Start** → **Windows Administrative Tools** → **Active Directory Users and Computers**
2. Expand `hariskhurshidltd.local`

### Step 3: Examine the Domain Structure

Document what you find:

```
hariskhurshidltd.local
├── Builtin
├── Computers
│   ├── hariskhurshidltdweb1
│   ├── hariskhurshidltdweb2
│   └── hariskhurshidltdsql1
├── Domain Controllers
│   └── hariskhurshidltd-dc
├── Users
│   └── Administrator
└── [Custom OUs if any]
```

### Step 4: Check Domain Info via PowerShell

```powershell
# Domain information
Get-ADDomain | Select-Object Name, DNSRoot, NetBIOSName, DomainMode, Forest

# Domain Controllers
Get-ADDomainController -Filter * | Select-Object Name, IPv4Address, OperatingSystem

# All computer accounts
Get-ADComputer -Filter * | Select-Object Name, DNSHostName, Enabled | Format-Table

# All user accounts
Get-ADUser -Filter * | Select-Object Name, SamAccountName, Enabled | Format-Table
```

### Step 5: Record Your Findings

| Item | Value |
|------|-------|
| Domain Name | |
| NetBIOS Name | |
| Domain Functional Level | |
| Number of DCs | |
| Number of Computer Accounts | |
| Number of User Accounts | |

---

## Exercise 2: Explore DNS

### Step 1: Open DNS Manager

On the DC, click **Start** → **Windows Administrative Tools** → **DNS**

### Step 2: Examine Forward Lookup Zones

1. Expand **Forward Lookup Zones**
2. Click `hariskhurshidltd.local`
3. Document all DNS records:

| Record Name | Type | Value |
|-------------|------|-------|
| hariskhurshidltd-dc | A | 192.168.100.10 |
| hariskhurshidltdweb1 | A | 192.168.100.20 |
| hariskhurshidltdweb2 | A | 192.168.100.21 |
| hariskhurshidltdsql1 | A | 192.168.100.30 |

### Step 3: Examine Reverse Lookup Zones

1. Expand **Reverse Lookup Zones**
2. Check for `100.168.192.in-addr.arpa`

### Step 4: Test DNS Resolution via PowerShell

```powershell
# Test forward lookups
Resolve-DnsName hariskhurshidltd-dc.hariskhurshidltd.local
Resolve-DnsName hariskhurshidltdweb1.hariskhurshidltd.local
Resolve-DnsName hariskhurshidltdsql1.hariskhurshidltd.local

# Test reverse lookup
Resolve-DnsName 192.168.100.10

# Check DNS server configuration
Get-DnsServerZone | Format-Table ZoneName, ZoneType, IsAutoCreated
```

---

## Exercise 3: Explore DHCP

### Step 1: Open DHCP Manager

On the DC or host, click **Start** → **Windows Administrative Tools** → **DHCP**

### Step 2: Examine DHCP Scope

1. Expand the server → **IPv4** → **Scope [192.168.100.0]**
2. Document:

| Setting | Value |
|---------|-------|
| Scope Name | LabNetwork |
| Start Range | 192.168.100.1 |
| End Range | 192.168.100.254 |
| Subnet Mask | 255.255.255.0 |
| Exclusion Range | 192.168.100.1 - 192.168.100.15 |
| Default Gateway | 192.168.100.1 |
| DNS Server | 168.63.129.16 |
| Lease Duration | 1 day |

### Step 3: Check DHCP via PowerShell

```powershell
# View DHCP scopes
Get-DhcpServerv4Scope | Format-Table

# View exclusion ranges
Get-DhcpServerv4ExclusionRange | Format-Table

# View active leases
Get-DhcpServerv4Lease -ScopeId 192.168.100.0 | Format-Table

# View scope options
Get-DhcpServerv4OptionValue -ScopeId 192.168.100.0 | Format-Table
```

---

## Exercise 4: Explore IIS Web Servers

### Step 1: Connect to Web Server 1

1. In Hyper-V Manager, right-click `hariskhurshidltdweb1` → **Connect**
2. Login: `HARISKLTD\Administrator` / `P@ssw0rd123!`

### Step 2: Open IIS Manager

1. Click **Start** → type **IIS** → Open **Internet Information Services (IIS) Manager**
2. Expand the server → **Sites**

### Step 3: Examine the Default Website

Document:

| Setting | Value |
|---------|-------|
| Site Name | |
| Physical Path | |
| Bindings | |
| Application Pool | |
| .NET CLR Version | |

### Step 4: Check IIS via PowerShell

```powershell
# Import IIS module
Import-Module WebAdministration

# List all websites
Get-Website | Format-Table Name, State, PhysicalPath

# List application pools
Get-ChildItem IIS:\AppPools | Format-Table Name, State, ManagedRuntimeVersion

# List bindings
Get-WebBinding | Format-Table

# Check IIS service
Get-Service W3SVC | Format-Table Name, Status, StartType
```

### Step 5: Test the Website

From the web server, open a browser:
```
http://localhost
```

From the Hyper-V host:
```
http://192.168.100.20
```

### Step 6: Compare Web Server 2

1. Connect to `hariskhurshidltdweb2`
2. Repeat the same checks
3. Note any differences between web1 and web2

---

## Exercise 5: Explore SQL Server

### Step 1: Connect to SQL Server VM

1. In Hyper-V Manager, right-click `hariskhurshidltdsql1` → **Connect**
2. Login: `HARISKLTD\Administrator` / `P@ssw0rd123!`

### Step 2: Open SQL Server Management Studio (SSMS)

1. Open **SSMS** from the Start menu
2. Connect with:
   - Server: `hariskhurshidltdsql1` or `localhost`
   - Authentication: **SQL Server Authentication**
   - Login: `sa`
   - Password: `P@ssw0rd123!`

### Step 3: Examine Databases

1. Expand **Databases**
2. Document all user databases:

| Database | Size | Recovery Model | Purpose |
|----------|------|---------------|---------|
| | | | |

### Step 4: Check SQL via PowerShell

```powershell
# Check SQL Server service
Get-Service MSSQLSERVER, SQLSERVERAGENT, SQLBrowser | Format-Table Name, Status, StartType

# Check SQL Server version
Invoke-Sqlcmd -Query "SELECT @@VERSION" -ServerInstance "localhost"

# List databases
Invoke-Sqlcmd -Query "SELECT name, state_desc, recovery_model_desc, compatibility_level FROM sys.databases" -ServerInstance "localhost"

# Check SQL logins
Invoke-Sqlcmd -Query "SELECT name, type_desc, is_disabled FROM sys.server_principals WHERE type IN ('S','U')" -ServerInstance "localhost"
```

### Step 5: Test Web-to-SQL Connectivity

From `hariskhurshidltdweb1`:
```powershell
# Test SQL port
Test-NetConnection -ComputerName 192.168.100.30 -Port 1433

# Test SQL connection
Invoke-Sqlcmd -Query "SELECT @@SERVERNAME, GETDATE()" -ServerInstance "192.168.100.30" -Username "webuser" -Password "WebP@ss123!"
```

---

## Exercise 6: Explore Linux Server

### Step 1: Connect to Linux VM

1. In Hyper-V Manager, right-click `hariskhurshidltdlinux1` → **Connect**
2. Login with the configured Linux credentials

### Step 2: Check System Information

```bash
# OS version
cat /etc/os-release

# Hostname
hostname

# IP address
ip addr show

# Disk usage
df -h

# Memory usage
free -h

# Running services
systemctl list-units --type=service --state=running
```

### Step 3: Check Network Connectivity

```bash
# Test gateway
ping -c 3 192.168.100.1

# Test DC
ping -c 3 192.168.100.10

# Test web server
curl -s -o /dev/null -w "%{http_code}" http://192.168.100.20

# Test internet
ping -c 3 8.8.8.8

# Test DNS
nslookup google.com
```

### Step 4: Check Web Server (if installed)

```bash
# Check Apache
systemctl status apache2

# Or check Nginx
systemctl status nginx

# Check what's listening
ss -tlnp
```

### Step 5: Note Key Differences

| Item | Windows VMs | Linux VM |
|------|-------------|----------|
| Domain Joined | Yes | No |
| Management | RDP / PowerShell | SSH / Bash |
| Web Server | IIS | Apache/Nginx |
| Secure Boot | ON | OFF |
| RAM | 4 GB | 2 GB |

---

## Exercise 7: Document the Environment

### Step 1: Create an Inventory

Complete this table with your findings:

| VM Name | IP | OS | Roles | Domain Joined | Key Services |
|---------|----|----|-------|---------------|-------------|
| hariskhurshidltd-dc | 192.168.100.10 | | | | |
| hariskhurshidltdweb1 | 192.168.100.20 | | | | |
| hariskhurshidltdweb2 | 192.168.100.21 | | | | |
| hariskhurshidltdsql1 | 192.168.100.30 | | | | |
| hariskhurshidltdlinux1 | 192.168.100.40 | | | | |

### Step 2: Document Dependencies

```
Web Application Flow:
  Client → Web Server (IIS:80) → SQL Server (SQL:1433) → Database

Authentication Flow:
  User → Domain Controller (Kerberos/NTLM) → Access Granted

DNS Resolution Flow:
  Client → DC (DNS:53) → hariskhurshidltd.local zone → IP Address
```

### Step 3: Identify Migration Considerations

For each VM, note:
- [ ] Operating system version and edition
- [ ] Installed roles and features
- [ ] Application dependencies
- [ ] Network requirements (ports, protocols)
- [ ] Data size (disk usage)
- [ ] Domain membership requirements
- [ ] Special configurations

---

## ✅ Module Complete!

You have successfully:
- [x] Explored Active Directory Domain Services
- [x] Examined DNS zones and records
- [x] Inspected DHCP configuration
- [x] Explored IIS web server settings
- [x] Connected to SQL Server and examined databases
- [x] Accessed and explored the Linux VM
- [x] Documented the complete environment
- [x] Identified migration considerations

---

## 💡 Key Takeaways

1. **HarisKhurshidLTD** runs a typical multi-tier application (Web + SQL + AD)
2. The environment has both **Windows** and **Linux** workloads
3. There are **dependencies** between VMs (Web depends on SQL, all Windows VMs depend on DC)
4. The Linux VM is **not domain joined** — different migration/management approach needed
5. This is exactly the type of environment Azure Migrate and Azure Arc are designed for

---

## ➡️ Next Module

Proceed to **[Module 02: Azure Migrate — Discover, Assess, Migrate](../module-02-azure-migrate/)**

---

*Azure Migrate & Arc Workshop — Haris Khurshid, MCT*
