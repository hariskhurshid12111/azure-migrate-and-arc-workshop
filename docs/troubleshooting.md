# 🔧 Troubleshooting Guide

Common issues and solutions for the Azure Migrate & Arc Workshop lab environment.

---

## Table of Contents

- [Deployment Issues](#deployment-issues)
- [Hyper-V Issues](#hyper-v-issues)
- [Network Issues](#network-issues)
- [VM Issues](#vm-issues)
- [Active Directory Issues](#active-directory-issues)
- [SQL Server Issues](#sql-server-issues)
- [Web Application Issues](#web-application-issues)
- [Azure Migrate Issues](#azure-migrate-issues)
- [Azure Arc Issues](#azure-arc-issues)
- [Log File Locations](#log-file-locations)

---

## Deployment Issues

### ❌ ARM template deployment fails with quota error

**Error:** `Operation results in exceeding quota limits of Core`

**Solution:**
1. Check your subscription's vCPU quota:
   - Azure Portal → Subscriptions → Usage + quotas
2. Try a different Azure region
3. Request a quota increase:
   - Azure Portal → Help + Support → New support request → Quota

---

### ❌ CustomScriptExtension times out

**Error:** `VMExtensionProvisioningError` or `Extension operation timed out`

**Cause:** VM downloads are large (~50-80 GB total). Can take 25-35 minutes.

**Solution:**
1. RDP into the host VM
2. Check the bootstrap log:
   ```powershell
   Get-Content C:\BootstrapHarisKhurshidLTDHost_log.txt -Tail 50
   ```
3. If downloads are still running, **wait** — don't restart
4. If downloads failed, re-run manually:
   ```powershell
   powershell -ExecutionPolicy Unrestricted -File "C:\HarisKhurshidLTDLab\scripts\BootstrapLabHost.ps1"
   ```

---

### ❌ Deployment succeeds but no VMs in Hyper-V

**Cause:** Post-reboot script hasn't run yet, or failed.

**Solution:**
1. Check if Hyper-V is installed:
   ```powershell
   Get-WindowsFeature Hyper-V
   ```
2. If not installed, the server hasn't rebooted yet. Wait or restart manually.
3. If installed, check the post-reboot log:
   ```powershell
   Get-Content "C:\HarisKhurshidLTDLab\PostRebootConfigure_log.txt" -Tail 50
   ```
4. If the scheduled task didn't run, run manually:
   ```powershell
   powershell -ExecutionPolicy Unrestricted -File "C:\HarisKhurshidLTDLab\scripts\PostRebootConfigure.ps1"
   ```

---

## Hyper-V Issues

### ❌ Hyper-V feature fails to install

**Error:** `Hyper-V cannot be installed: The processor does not have required virtualization capabilities`

**Cause:** VM size doesn't support nested virtualization.

**Solution:**
- Use one of these VM sizes:
  - `Standard_D8s_v3` (recommended)
  - `Standard_D16s_v3`
  - `Standard_E8s_v3`
  - `Standard_D8s_v5`
  - `Standard_D16s_v5`

---

### ❌ VMs show "Off" state in Hyper-V Manager

**Solution:**
1. Start DC first:
   ```powershell
   Start-VM -Name "hariskhurshidltd-dc"
   ```
2. Wait 2-3 minutes for AD to initialize
3. Start remaining VMs:
   ```powershell
   Start-VM -Name "hariskhurshidltdweb1"
   Start-VM -Name "hariskhurshidltdweb2"
   Start-VM -Name "hariskhurshidltdsql1"
   Start-VM -Name "hariskhurshidltdlinux1"
   ```

---

### ❌ VM fails to start — "Not enough memory"

**Cause:** Host doesn't have enough free RAM.

**Solution:**
1. Check available memory:
   ```powershell
   Get-VMMemory * | Select VMName, Startup
   systeminfo | findstr "Available Physical Memory"
   ```
2. Reduce VM memory if needed:
   ```powershell
   Stop-VM -Name "hariskhurshidltdlinux1" -Force
   Set-VM -Name "hariskhurshidltdlinux1" -MemoryStartupBytes 1GB
   Start-VM -Name "hariskhurshidltdlinux1"
   ```
3. Or upgrade to `Standard_D16s_v3` (64 GB RAM)

---

## Network Issues

### ❌ Nested VMs have no internet access

**Cause:** NAT not configured properly.

**Solution:**
1. Verify the virtual switch exists:
   ```powershell
   Get-VMSwitch
   ```
2. Verify the NAT IP:
   ```powershell
   Get-NetIPAddress -InterfaceAlias "*InternalNATSwitch*"
   ```
3. Verify NAT:
   ```powershell
   Get-NetNat
   ```
4. If missing, recreate:
   ```powershell
   New-VMSwitch -Name "InternalNATSwitch" -SwitchType Internal
   $adapter = Get-NetAdapter | Where-Object { $_.Name -like "*InternalNATSwitch*" }
   New-NetIPAddress -IPAddress 192.168.100.1 -PrefixLength 24 -InterfaceIndex $adapter.ifIndex
   New-NetNat -Name "InternalNat" -InternalIPInterfaceAddressPrefix "192.168.100.0/24"
   ```

---

### ❌ Cannot ping between nested VMs

**Cause:** Windows Firewall blocking ICMP.

**Solution:** On each Windows VM, run:
```powershell
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
```

---

### ❌ Cannot RDP to nested VMs from host

**Solution:**
1. From the Hyper-V host, use `vmconnect` or Hyper-V Manager → Connect
2. For RDP, ensure the VM has the correct IP:
   ```powershell
   # Run inside the nested VM
   ipconfig /all
   ```
3. Ensure RDP is enabled on the nested VM:
   ```powershell
   Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
   Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
   ```

---

## VM Issues

### ❌ VHDX files not found after extraction

**Solution:**
1. Check if downloads completed:
   ```powershell
   Get-ChildItem F:\TempDownloads\ -Recurse | Select Name, Length
   ```
2. Check extracted files:
   ```powershell
   Get-ChildItem F:\VirtualMachines\ -Recurse -Filter "*.vhdx" | Select FullName, @{N='SizeGB';E={[math]::Round($_.Length/1GB,2)}}
   ```
3. If `.7z` files exist but not extracted, re-extract:
   ```powershell
   & "C:\Program Files\7-Zip\7z.exe" x "F:\TempDownloads\hariskhurshidltd-dc.7z" -o"F:\VirtualMachines\hariskhurshidltd-dc" -y
   ```

---

### ❌ 7-Zip not installed or not found

**Solution:**
```powershell
# Check if 7-Zip exists
Test-Path "C:\Program Files\7-Zip\7z.exe"

# If not, download and install
Invoke-WebRequest -Uri "https://hariskhurshid.blob.core.windows.net/hariskhurshidltd/7z2600-x64.exe" -OutFile "$env:TEMP\7z.exe" -UseBasicParsing
Start-Process -FilePath "$env:TEMP\7z.exe" -ArgumentList "/S" -Wait
```

---

## Active Directory Issues

### ❌ Domain join fails for VMs

**Cause:** DC not fully started or DNS not configured.

**Solution:**
1. Ensure DC is running and AD services are up:
   ```powershell
   # Connect to DC and check
   Get-Service NTDS, DNS, Netlogon
   ```
2. Verify DNS points to DC:
   ```powershell
   # On the VM that can't join
   nslookup hariskhurshidltd.local 192.168.100.10
   ```
3. Set DNS to DC IP:
   ```powershell
   Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.100.10
   ```

---

### ❌ Cannot login with domain credentials

**Credentials:**
| Account | Username | Password |
|---------|----------|----------|
| Domain Admin | HARISKLTD\Administrator | P@ssw0rd123! |
| Local Admin | .\localuser | *(set during deploy)* |

**Solution:**
- Use NetBIOS format: `HARISKLTD\Administrator`
- Or UPN format: `Administrator@hariskhurshidltd.local`
- Make sure the DC is running first

---

## SQL Server Issues

### ❌ Cannot connect to SQL Server

**Solution:**
1. Verify SQL service is running:
   ```powershell
   # On hariskhurshidltdsql1
   Get-Service MSSQLSERVER, SQLSERVERAGENT
   ```
2. Test connection from web server:
   ```powershell
   Test-NetConnection -ComputerName 192.168.100.30 -Port 1433
   ```
3. Verify SQL Authentication:
   - SA: `sa` / `P@ssw0rd123!`
   - Web: `webuser` / `WebP@ss123!`
4. Ensure SQL Browser is running:
   ```powershell
   Get-Service SQLBrowser
   Start-Service SQLBrowser
   ```

---

### ❌ SQL Server firewall blocking connections

**Solution:** On hariskhurshidltdsql1:
```powershell
New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "SQL Browser" -Direction Inbound -LocalPort 1434 -Protocol UDP -Action Allow
```

---

## Web Application Issues

### ❌ Website not loading at http://192.168.100.20

**Solution:**
1. Check IIS is running:
   ```powershell
   # On hariskhurshidltdweb1
   Get-Service W3SVC
   iisreset /status
   ```
2. Check the default site:
   ```powershell
   Import-Module WebAdministration
   Get-Website
   ```
3. Test locally on the web server:
   ```powershell
   Invoke-WebRequest -Uri http://localhost -UseBasicParsing
   ```
4. Check firewall:
   ```powershell
   New-NetFirewallRule -DisplayName "HTTP" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
   ```

---

## Azure Migrate Issues

### ❌ Azure Migrate appliance cannot discover VMs

**Solution:**
1. Ensure the appliance has network access to all VMs
2. Verify WinRM is enabled on Windows VMs:
   ```powershell
   Enable-PSRemoting -Force
   Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
   ```
3. For Linux VM, ensure SSH is enabled:
   ```bash
   sudo systemctl status ssh
   sudo systemctl enable ssh --now
   ```

---

### ❌ Azure Migrate replication fails

**Solution:**
1. Ensure VMs have internet access (through NAT)
2. Check Azure Migrate project settings
3. Verify the replication provider is installed
4. Check the Azure Migrate appliance logs

---

## Azure Arc Issues

### ❌ Arc agent installation fails

**Solution:**
1. Ensure the VM has internet access:
   ```powershell
   Test-NetConnection -ComputerName "login.microsoftonline.com" -Port 443
   Test-NetConnection -ComputerName "management.azure.com" -Port 443
   ```
2. Check proxy settings if applicable
3. Run the Arc agent install script with elevated permissions
4. Check Arc agent logs:
   ```
   C:\ProgramData\AzureConnectedMachineAgent\Log\
   ```

---

### ❌ Arc-enabled server shows "Disconnected"

**Solution:**
1. Check the agent service:
   ```powershell
   Get-Service himds
   Restart-Service himds
   ```
2. Verify connectivity:
   ```powershell
   & "$env:ProgramFiles\AzureConnectedMachineAgent\azcmagent.exe" check
   ```

---

## Log File Locations

| Log | Path |
|-----|------|
| Bootstrap Script | `C:\BootstrapHarisKhurshidLTDHost_log.txt` |
| Post-Reboot Script | `C:\HarisKhurshidLTDLab\PostRebootConfigure_log.txt` |
| ARM Extension | `C:\WindowsAzure\Logs\Plugins\Microsoft.Compute.CustomScriptExtension\` |
| Hyper-V | Event Viewer → Applications and Services → Microsoft → Windows → Hyper-V |
| Azure Arc Agent | `C:\ProgramData\AzureConnectedMachineAgent\Log\` |
| Azure Migrate | Appliance configuration manager logs |
| IIS | `C:\inetpub\logs\LogFiles\` |
| SQL Server | SQL Server Error Log via SSMS |

---

## Quick Diagnostic Script

Run this on the Hyper-V host to check overall lab health:

```powershell
Write-Host "========== LAB HEALTH CHECK ==========" -ForegroundColor Cyan

Write-Host "`n--- Hyper-V Service ---" -ForegroundColor Yellow
Get-Service vmms | Format-Table Name, Status

Write-Host "`n--- Virtual Switch ---" -ForegroundColor Yellow
Get-VMSwitch | Format-Table Name, SwitchType

Write-Host "`n--- NAT ---" -ForegroundColor Yellow
Get-NetNat | Format-Table Name, InternalIPInterfaceAddressPrefix

Write-Host "`n--- VM Status ---" -ForegroundColor Yellow
Get-VM | Format-Table Name, State, CPUUsage, @{L='MemGB';E={[math]::Round($_.MemoryAssigned/1GB,1)}}, Uptime

Write-Host "`n--- VHDX Files ---" -ForegroundColor Yellow
Get-ChildItem F:\VirtualMachines -Recurse -Filter "*.vhdx" | Select FullName, @{L='SizeGB';E={[math]::Round($_.Length/1GB,2)}}

Write-Host "`n--- Network Test ---" -ForegroundColor Yellow
@('192.168.100.10','192.168.100.20','192.168.100.21','192.168.100.30','192.168.100.40') | ForEach-Object {
    $result = Test-NetConnection -ComputerName $_ -Port 3389 -WarningAction SilentlyContinue
    Write-Host "  $_ RDP: $($result.TcpTestSucceeded)" -ForegroundColor $(if($result.TcpTestSucceeded){'Green'}else{'Red'})
}

Write-Host "`n========== END HEALTH CHECK ==========" -ForegroundColor Cyan
```

---

## Still Stuck?

1. Check the [Architecture](architecture.md) document for expected configuration
2. Open an [Issue](https://github.com/hariskhurshid12111/azure-migrate-and-arc-workshop/issues/new?template=bug_report.md) with logs attached
3. Include output from the **Quick Diagnostic Script** above

---

*Maintained by Haris Khurshid, MCT — [GitHub](https://github.com/hariskhurshid12111)*
