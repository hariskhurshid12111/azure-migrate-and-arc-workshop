# 🚀 Module 00: Deploy Lab Environment

## Overview

In this module, you will deploy the complete lab environment using a one-click Azure ARM template. By the end, you will have a fully functional on-premises simulation with 5 nested Hyper-V virtual machines.

---

## ⏱️ Estimated Time: 45-60 minutes

---

## 🎯 Objectives

After completing this module, you will be able to:

- Deploy an ARM template using the Azure Portal
- Understand nested virtualization in Azure
- Verify a Hyper-V environment with multiple VMs
- Connect to nested VMs using Hyper-V Manager
- Validate network connectivity between VMs

---

## 📋 Prerequisites

- Azure subscription with **Contributor** access
- Ability to deploy VMs with **8+ vCPUs** (quota check)
- RDP client installed (Windows built-in or Microsoft Remote Desktop)
- Modern web browser

---

## Exercise 1: Deploy the ARM Template

### Step 1: Click Deploy to Azure

Click the button below to start deployment:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhariskhurshid12111%2Fazure-migrate-and-arc-workshop%2Fmain%2Fdeploy%2Fazuredeploy.json)

### Step 2: Fill in Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Subscription** | Your subscription | Must have Contributor access |
| **Resource Group** | Create new: `rg-hkltd-workshop` | Or use existing |
| **Region** | East US (recommended) | Must support D8s_v3 |
| **Admin Username** | `localuser` | Default — can change |
| **Admin Password** | Your strong password | Minimum 12 characters, include uppercase, lowercase, number, special char |
| **Student Name** | Your name (no spaces) | e.g., `student01` or `haris` |
| **VM Size** | `Standard_D8s_v3` | Default — recommended |

### Step 3: Deploy

1. Click **"Review + create"**
2. Review the summary
3. Click **"Create"**
4. Wait for deployment to complete (~10 minutes for Azure resources)

### Step 4: Wait for Full Setup

> ⚠️ **Important:** Even after Azure says "deployment complete", the lab is NOT ready yet!

The CustomScriptExtension is still:
- Downloading 5 VM images (~50-80 GB)
- Decompressing VMs
- Installing Hyper-V
- Rebooting the server
- Creating and starting nested VMs

**Total time: 45-60 minutes from clicking Deploy**

---

## Exercise 2: Connect to the Lab Host

### Step 1: Get Connection Info

1. Go to the **Resource Group** → Click the **VM** (`HKLTDHost-{studentName}`)
2. Copy the **DNS name** from the Overview page
   - Format: `hkltdhost-{studentname}.{region}.cloudapp.azure.com`
3. Or find it in **Deployment Outputs**:
   - `publicFQDN`: The DNS name
   - `rdpCommand`: Ready-to-use RDP command

### Step 2: RDP to Host VM

**Option A — Using RDP command:**
```
mstsc /v:hkltdhost-{studentname}.{region}.cloudapp.azure.com
```

**Option B — Using Remote Desktop:**
1. Open **Remote Desktop Connection**
2. Enter the DNS name
3. Click **Connect**
4. Enter credentials:
   - Username: `localuser`
   - Password: *(the password you set during deployment)*

### Step 3: Verify You're Connected

You should see:
- Windows Server 2019 Desktop
- `LAB-README.txt` on the Desktop
- `Open Lab Website.url` on the Desktop

---

## Exercise 3: Verify Hyper-V Environment

### Step 1: Open Hyper-V Manager

1. Click **Start** → type **Hyper-V Manager** → Open it
2. Click on the server name in the left panel

### Step 2: Verify All 5 VMs Are Running

You should see:

| VM Name | State | Expected |
|---------|-------|----------|
| hariskhurshidltd-dc | Running ✅ | AD Domain Controller |
| hariskhurshidltdweb1 | Running ✅ | IIS Web Server |
| hariskhurshidltdweb2 | Running ✅ | IIS Web Server |
| hariskhurshidltdsql1 | Running ✅ | SQL Server 2019 |
| hariskhurshidltdlinux1 | Running ✅ | Ubuntu 22.04 |

> ⚠️ If VMs show "Off", wait a few more minutes. The post-reboot script may still be running. Check: `C:\HarisKhurshidLTDLab\PostRebootConfigure_log.txt`

### Step 3: Verify VM Resources

Right-click any VM → **Settings** to verify:
- **Memory:** 4 GB (2 GB for Linux)
- **Processors:** 2 vCPU
- **Network:** Connected to `InternalNATSwitch`
- **Hard Drive:** VHDX from `F:\VirtualMachines\`

---

## Exercise 4: Verify Network Connectivity

### Step 1: Open PowerShell on Host

Open **PowerShell as Administrator** on the Hyper-V host.

### Step 2: Ping All VMs

```powershell
# Test connectivity to all nested VMs
Test-NetConnection -ComputerName 192.168.100.10 -Port 3389  # DC
Test-NetConnection -ComputerName 192.168.100.20 -Port 80    # Web1
Test-NetConnection -ComputerName 192.168.100.21 -Port 80    # Web2
Test-NetConnection -ComputerName 192.168.100.30 -Port 1433  # SQL1
Test-NetConnection -ComputerName 192.168.100.40 -Port 22    # Linux1
```

### Step 3: Verify NAT and Switch

```powershell
# Check virtual switch
Get-VMSwitch | Format-Table Name, SwitchType

# Check NAT configuration
Get-NetNat | Format-Table Name, InternalIPInterfaceAddressPrefix

# Check host adapter IP
Get-NetIPAddress -InterfaceAlias "*InternalNATSwitch*" | Format-Table IPAddress, PrefixLength
```

**Expected output:**
- VMSwitch: `InternalNATSwitch` (Internal)
- NAT: `InternalNat` (192.168.100.0/24)
- Host IP: `192.168.100.1/24`

---

## Exercise 5: Connect to Nested VMs

### Step 1: Connect to Domain Controller

1. In Hyper-V Manager, right-click `hariskhurshidltd-dc` → **Connect**
2. Login with:
   - Username: `HARISKLTD\Administrator`
   - Password: `P@ssw0rd123!`
3. Verify Active Directory is running:
   ```powershell
   Get-Service NTDS, DNS, Netlogon | Format-Table Name, Status
   ```

### Step 2: Connect to Web Server

1. Right-click `hariskhurshidltdweb1` → **Connect**
2. Login with: `HARISKLTD\Administrator` / `P@ssw0rd123!`
3. Verify IIS:
   ```powershell
   Get-Service W3SVC | Format-Table Name, Status
   ```

### Step 3: Test the Web Application

From the **Hyper-V host**, open a browser and go to:

```
http://192.168.100.20
```

You should see the HarisKhurshidLTD web application running!

---

## Exercise 6: Run Health Check

Run this script on the Hyper-V host to verify everything:

```powershell
Write-Host "========== LAB HEALTH CHECK ==========" -ForegroundColor Cyan

# Check VMs
Write-Host "`n--- VM Status ---" -ForegroundColor Yellow
Get-VM | Format-Table Name, State, CPUUsage, @{L='MemGB';E={[math]::Round($_.MemoryAssigned/1GB,1)}}

# Check Network
Write-Host "`n--- Connectivity ---" -ForegroundColor Yellow
$ips = @(
    @{Name='DC';    IP='192.168.100.10'; Port=3389},
    @{Name='Web1';  IP='192.168.100.20'; Port=80},
    @{Name='Web2';  IP='192.168.100.21'; Port=80},
    @{Name='SQL1';  IP='192.168.100.30'; Port=1433},
    @{Name='Linux1';IP='192.168.100.40'; Port=22}
)

foreach ($vm in $ips) {
    $result = Test-NetConnection -ComputerName $vm.IP -Port $vm.Port -WarningAction SilentlyContinue
    $status = if ($result.TcpTestSucceeded) { "PASS" } else { "FAIL" }
    $color = if ($result.TcpTestSucceeded) { "Green" } else { "Red" }
    Write-Host "  $($vm.Name) ($($vm.IP):$($vm.Port)): $status" -ForegroundColor $color
}

Write-Host "`n========== END HEALTH CHECK ==========" -ForegroundColor Cyan
```

---

## ✅ Module Complete!

You have successfully:
- [x] Deployed the ARM template to Azure
- [x] Connected to the Hyper-V host via RDP
- [x] Verified all 5 nested VMs are running
- [x] Confirmed network connectivity
- [x] Connected to nested VMs
- [x] Tested the web application
- [x] Ran the health check script

---

## ➡️ Next Module

Proceed to **[Module 01: Explore On-Premises Environment](../module-01-explore-onprem/)**

---

*Azure Migrate & Arc Workshop — Haris Khurshid, MCT*
