#==============================================================================
# BootstrapHarisKhurshidLTDHost.ps1
# Azure Migrate & Arc Workshop — Lab Host Bootstrap Script
# Author: Haris Khurshid, MCT
# Description: Downloads pre-configured VMs, installs Hyper-V, prepares host
#==============================================================================

Start-Transcript -Path "C:\BootstrapHarisKhurshidLTDHost_log.txt" -Append
$ErrorActionPreference = 'SilentlyContinue'

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " HarisKhurshidLTD Lab Bootstrap Starting" -ForegroundColor Cyan
Write-Host " $(Get-Date)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

#--- Variables ---
$storageBase = 'https://hariskhurshid.blob.core.windows.net/hariskhurshidltd'
$labDir      = 'C:\HarisKhurshidLTDLab'
$scriptsDir  = "$labDir\scripts"
$vhdDir      = 'F:\VirtualMachines'
$tempDir     = 'F:\TempDownloads'

#--- VM Definitions ---
$vms = @(
    @{ Name = 'hariskhurshidltd-dc';     File = 'hariskhurshidltd-dc.7z' }
    @{ Name = 'hariskhurshidltdweb1';    File = 'hariskhurshidltdweb1.7z' }
    @{ Name = 'hariskhurshidltdweb2';    File = 'hariskhurshidltdweb2.7z' }
    @{ Name = 'hariskhurshidltdsql1';    File = 'hariskhurshidltdsql1.7z' }
    @{ Name = 'hariskhurshidltdlinux1';  File = 'hariskhurshidltdlinux1.7z' }
)

#==============================================================================
# STEP 1: Disable IE Enhanced Security Configuration
#==============================================================================
Write-Host "`n[STEP 1] Disabling IE Enhanced Security..." -ForegroundColor Yellow
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey  = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
Set-ItemProperty -Path $UserKey  -Name "IsInstalled" -Value 0 -Force
Write-Host "  IE ESC disabled." -ForegroundColor Green

#==============================================================================
# STEP 2: Install Google Chrome
#==============================================================================
Write-Host "`n[STEP 2] Installing Google Chrome..." -ForegroundColor Yellow
try {
    $chromePath = "$env:TEMP\chrome_installer.exe"
    Invoke-WebRequest -Uri "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $chromePath -UseBasicParsing
    Start-Process -FilePath $chromePath -ArgumentList "/silent /install" -Wait -NoNewWindow
    Remove-Item $chromePath -Force -ErrorAction SilentlyContinue
    Write-Host "  Chrome installed." -ForegroundColor Green
} catch {
    Write-Host "  Chrome install failed (non-critical): $_" -ForegroundColor Yellow
}

#==============================================================================
# STEP 3: Create Lab Directories
#==============================================================================
Write-Host "`n[STEP 3] Creating lab directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $labDir -Force | Out-Null
New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null
Write-Host "  Created: $labDir" -ForegroundColor Green
Write-Host "  Created: $scriptsDir" -ForegroundColor Green

#==============================================================================
# STEP 4: Format Data Disk as F: Drive
#==============================================================================
Write-Host "`n[STEP 4] Formatting data disk..." -ForegroundColor Yellow
$rawDisk = Get-Disk | Where-Object { $_.PartitionStyle -eq 'RAW' -and $_.Size -gt 200GB } | Select-Object -First 1
if ($rawDisk) {
    Initialize-Disk -Number $rawDisk.Number -PartitionStyle GPT -Confirm:$false
    $partition = New-Partition -DiskNumber $rawDisk.Number -UseMaximumSize -DriveLetter F
    Format-Volume -DriveLetter F -FileSystem NTFS -NewFileSystemLabel "HKLTD-DATA" -Confirm:$false
    Write-Host "  Data disk formatted as F: (HKLTD-DATA)" -ForegroundColor Green
} else {
    Write-Host "  No RAW disk found — F: may already be configured" -ForegroundColor Yellow
}

New-Item -ItemType Directory -Path $vhdDir -Force | Out-Null
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Write-Host "  Created: $vhdDir" -ForegroundColor Green
Write-Host "  Created: $tempDir" -ForegroundColor Green

#==============================================================================
# STEP 5: Download and Install 7-Zip
#==============================================================================
Write-Host "`n[STEP 5] Installing 7-Zip..." -ForegroundColor Yellow
$7zInstallerUrl  = "$storageBase/7z2600-x64.exe"
$7zInstallerPath = "$tempDir\7z2600-x64.exe"
$7zExe           = "C:\Program Files\7-Zip\7z.exe"

try {
    Start-BitsTransfer -Source $7zInstallerUrl -Destination $7zInstallerPath -ErrorAction Stop
} catch {
    Invoke-WebRequest -Uri $7zInstallerUrl -OutFile $7zInstallerPath -UseBasicParsing
}

Start-Process -FilePath $7zInstallerPath -ArgumentList "/S" -Wait -NoNewWindow
Start-Sleep -Seconds 10

if (Test-Path $7zExe) {
    Write-Host "  7-Zip installed successfully at: $7zExe" -ForegroundColor Green
} else {
    Write-Host "  ERROR: 7-Zip not found at $7zExe" -ForegroundColor Red
    Stop-Transcript
    throw "7-Zip installation failed"
}

#==============================================================================
# STEP 6: Download PostRebootConfigure.ps1
#==============================================================================
Write-Host "`n[STEP 6] Downloading PostRebootConfigure.ps1..." -ForegroundColor Yellow
$postRebootUrl  = "$storageBase/PostRebootConfigure.ps1"
$postRebootDest = "$scriptsDir\PostRebootConfigure.ps1"

try {
    Start-BitsTransfer -Source $postRebootUrl -Destination $postRebootDest -ErrorAction Stop
} catch {
    Invoke-WebRequest -Uri $postRebootUrl -OutFile $postRebootDest -UseBasicParsing
}
Write-Host "  Downloaded: $postRebootDest" -ForegroundColor Green

#==============================================================================
# STEP 7: Download and Decompress VMs
#==============================================================================
Write-Host "`n[STEP 7] Downloading and decompressing VMs..." -ForegroundColor Yellow

foreach ($vm in $vms) {
    $vmName     = $vm.Name
    $vmFile     = $vm.File
    $extractDir = "$vhdDir\$vmName"
    $downloadUrl  = "$storageBase/$vmFile"
    $downloadDest = "$tempDir\$vmFile"
    $finalVhdx    = "$extractDir\$vmName.vhdx"

    Write-Host "`n  --- Processing: $vmName ---" -ForegroundColor Cyan

    # Skip if already extracted
    if (Test-Path $finalVhdx) {
        $size = (Get-Item $finalVhdx).Length / 1GB
        if ($size -gt 1) {
            Write-Host "    Already extracted ($([math]::Round($size,2)) GB) — skipping" -ForegroundColor Green
            continue
        }
    }

    # Create extract directory
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

    # Download
    Write-Host "    Downloading $vmFile..." -ForegroundColor White
    try {
        Start-BitsTransfer -Source $downloadUrl -Destination $downloadDest -ErrorAction Stop
        Write-Host "    Downloaded via BITS" -ForegroundColor Green
    } catch {
        Write-Host "    BITS failed, using Invoke-WebRequest..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadDest -UseBasicParsing
        Write-Host "    Downloaded via WebRequest" -ForegroundColor Green
    }

    # Decompress
    Write-Host "    Decompressing $vmFile..." -ForegroundColor White
    & $7zExe x "$downloadDest" -o"$extractDir" -y | Out-Null
    Write-Host "    Decompressed to: $extractDir" -ForegroundColor Green

    # Find and move VHDX to correct location
    $vhdxFiles = Get-ChildItem -Path $extractDir -Filter "*.vhdx" -Recurse | Where-Object { $_.Length -gt 1GB }
    if ($vhdxFiles) {
        $sourceVhdx = $vhdxFiles[0].FullName
        if ($sourceVhdx -ne $finalVhdx) {
            Move-Item -Path $sourceVhdx -Destination $finalVhdx -Force
            Write-Host "    Moved VHDX to: $finalVhdx" -ForegroundColor Green
        }
        # Clean up nested folders (keep only the vhdx)
        Get-ChildItem -Path $extractDir -Directory | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "    WARNING: No VHDX found after extraction!" -ForegroundColor Red
    }

    # Delete compressed file
    Remove-Item -Path $downloadDest -Force -ErrorAction SilentlyContinue
    Write-Host "    Cleaned up: $vmFile" -ForegroundColor Green
}

#==============================================================================
# STEP 8: Verify All VHDs
#==============================================================================
Write-Host "`n[STEP 8] Verifying VHDs..." -ForegroundColor Yellow
$allGood = $true
foreach ($vm in $vms) {
    $vhdPath = "$vhdDir\$($vm.Name)\$($vm.Name).vhdx"
    if (Test-Path $vhdPath) {
        $size = [math]::Round((Get-Item $vhdPath).Length / 1GB, 2)
        Write-Host "  OK: $($vm.Name).vhdx ($size GB)" -ForegroundColor Green
    } else {
        Write-Host "  MISSING: $vhdPath" -ForegroundColor Red
        $allGood = $false
    }
}

if (-not $allGood) {
    Write-Host "  WARNING: Some VHDs are missing!" -ForegroundColor Red
}

#==============================================================================
# STEP 9: Install and Configure DHCP
#==============================================================================
Write-Host "`n[STEP 9] Installing DHCP..." -ForegroundColor Yellow
Install-WindowsFeature -Name DHCP -IncludeManagementTools | Out-Null

Add-DhcpServerv4Scope -Name "LabNetwork" `
    -StartRange 192.168.100.1 `
    -EndRange 192.168.100.254 `
    -SubnetMask 255.255.255.0 `
    -State Active

Add-DhcpServerv4ExclusionRange -ScopeId 192.168.100.0 `
    -StartRange 192.168.100.1 `
    -EndRange 192.168.100.15

Set-DhcpServerv4OptionValue -ScopeId 192.168.100.0 `
    -Router 192.168.100.1

Set-DhcpServerv4OptionValue -ScopeId 192.168.100.0 `
    -DnsServer 168.63.129.16

Set-DhcpServerv4Scope -ScopeId 192.168.100.0 `
    -LeaseDuration (New-TimeSpan -Days 1)

Write-Host "  DHCP configured: 192.168.100.0/24" -ForegroundColor Green

#==============================================================================
# STEP 10: Create Desktop Shortcuts
#==============================================================================
Write-Host "`n[STEP 10] Creating desktop shortcuts..." -ForegroundColor Yellow

$readmeContent = @"
================================================================
  HarisKhurshidLTD - Azure Migrate & Arc Workshop
  Lab Environment Information
================================================================

DOMAIN:     hariskhurshidltd.local
NETBIOS:    HARISKLTD
SUBNET:     192.168.100.0/24

CREDENTIALS:
  Domain Admin:  HARISKLTD\Administrator  /  P@ssw0rd123!
  SQL SA:        sa                       /  P@ssw0rd123!
  SQL Web User:  webuser                  /  WebP@ss123!

VIRTUAL MACHINES:
  hariskhurshidltd-dc     192.168.100.10   AD Domain Controller + DNS
  hariskhurshidltdweb1    192.168.100.20   IIS Web Server + ASP.NET
  hariskhurshidltdweb2    192.168.100.21   IIS Web Server + ASP.NET
  hariskhurshidltdsql1    192.168.100.30   SQL Server 2019
  hariskhurshidltdlinux1  192.168.100.40   Ubuntu 22.04 LTS

LAB WEBSITE:
  http://192.168.100.20

QUICK START:
  1. Open Hyper-V Manager
  2. All VMs should be running
  3. Connect to any VM using credentials above
  4. Open http://192.168.100.20 to test the website
================================================================
"@

$readmeContent | Out-File -FilePath "C:\Users\Public\Desktop\LAB-README.txt" -Encoding UTF8

$urlContent = @"
[InternetShortcut]
URL=http://192.168.100.20
"@
$urlContent | Out-File -FilePath "C:\Users\Public\Desktop\Open Lab Website.url" -Encoding UTF8

Write-Host "  Desktop shortcuts created." -ForegroundColor Green

#==============================================================================
# STEP 11: Register Scheduled Task for Post-Reboot
#==============================================================================
Write-Host "`n[STEP 11] Registering post-reboot scheduled task..." -ForegroundColor Yellow

$taskAction  = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Unrestricted -File `"$scriptsDir\PostRebootConfigure.ps1`""
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

Register-ScheduledTask -TaskName "HarisKhurshidLTD-LabSetup" `
    -Action $taskAction `
    -Trigger $taskTrigger `
    -Principal $taskPrincipal `
    -Description "Post-reboot lab configuration for HarisKhurshidLTD Workshop" `
    -Force

Write-Host "  Scheduled task registered: HarisKhurshidLTD-LabSetup" -ForegroundColor Green

#==============================================================================
# STEP 12: Install Hyper-V and Restart
#==============================================================================
Write-Host "`n[STEP 12] Installing Hyper-V (will restart)..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Bootstrap complete! Installing Hyper-V..." -ForegroundColor Cyan
Write-Host " Server will restart automatically." -ForegroundColor Cyan
Write-Host " After restart, VMs will be created." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Stop-Transcript

Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
