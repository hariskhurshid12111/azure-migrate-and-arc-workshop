#==============================================================================
# PostRebootConfigure.ps1
# Azure Migrate & Arc Workshop — Post-Reboot VM Configuration
# Author: Haris Khurshid, MCT
# Description: Creates Hyper-V switch, NAT, and starts nested VMs
#==============================================================================

Start-Transcript -Path "C:\HarisKhurshidLTDLab\PostRebootConfigure_log.txt" -Append

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " HarisKhurshidLTD Post-Reboot Config" -ForegroundColor Cyan
Write-Host " $(Get-Date)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

#--- Variables ---
$vhdDir = 'F:\VirtualMachines'

#==============================================================================
# STEP 1: Wait for Hyper-V Service
#==============================================================================
Write-Host "`n[STEP 1] Waiting for Hyper-V service..." -ForegroundColor Yellow
$retries = 0
$maxRetries = 30
while ($retries -lt $maxRetries) {
    $svc = Get-Service -Name vmms -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') {
        Write-Host "  Hyper-V service is running." -ForegroundColor Green
        break
    }
    $retries++
    Write-Host "  Waiting... ($retries/$maxRetries)" -ForegroundColor White
    Start-Sleep -Seconds 10
}

if ($retries -eq $maxRetries) {
    Write-Host "  ERROR: Hyper-V service did not start!" -ForegroundColor Red
    Stop-Transcript
    throw "Hyper-V service failed to start"
}

#==============================================================================
# STEP 2: Create Virtual Switch and NAT
#==============================================================================
Write-Host "`n[STEP 2] Creating virtual switch and NAT..." -ForegroundColor Yellow

# Create Internal Switch
$existingSwitch = Get-VMSwitch -Name "InternalNATSwitch" -ErrorAction SilentlyContinue
if (-not $existingSwitch) {
    New-VMSwitch -Name "InternalNATSwitch" -SwitchType Internal
    Write-Host "  Created VMSwitch: InternalNATSwitch" -ForegroundColor Green
} else {
    Write-Host "  VMSwitch already exists." -ForegroundColor Green
}

# Set Host IP on Switch Adapter
Start-Sleep -Seconds 5
$adapter = Get-NetAdapter | Where-Object { $_.Name -like "*InternalNATSwitch*" }
if ($adapter) {
    $existingIP = Get-NetIPAddress -InterfaceIndex $adapter.ifIndex -IPAddress "192.168.100.1" -ErrorAction SilentlyContinue
    if (-not $existingIP) {
        New-NetIPAddress -IPAddress 192.168.100.1 -PrefixLength 24 -InterfaceIndex $adapter.ifIndex
        Write-Host "  Set IP: 192.168.100.1/24" -ForegroundColor Green
    } else {
        Write-Host "  IP already configured." -ForegroundColor Green
    }
} else {
    Write-Host "  ERROR: Could not find NAT switch adapter!" -ForegroundColor Red
}

# Create NAT
$existingNat = Get-NetNat -Name "InternalNat" -ErrorAction SilentlyContinue
if (-not $existingNat) {
    New-NetNat -Name "InternalNat" -InternalIPInterfaceAddressPrefix "192.168.100.0/24"
    Write-Host "  Created NAT: InternalNat (192.168.100.0/24)" -ForegroundColor Green
} else {
    Write-Host "  NAT already exists." -ForegroundColor Green
}

#==============================================================================
# STEP 3: Find VHDX Helper Function
#==============================================================================
function Find-Vhdx {
    param([string]$VMName)

    $directPath = "$vhdDir\$VMName\$VMName.vhdx"
    if (Test-Path $directPath) {
        return $directPath
    }

    # Search recursively
    $found = Get-ChildItem -Path "$vhdDir\$VMName" -Filter "*.vhdx" -Recurse -ErrorAction SilentlyContinue |
             Where-Object { $_.Length -gt 1GB } |
             Select-Object -First 1

    if ($found) {
        return $found.FullName
    }

    # Search entire VHD directory
    $found = Get-ChildItem -Path $vhdDir -Filter "$VMName*.vhdx" -Recurse -ErrorAction SilentlyContinue |
             Where-Object { $_.Length -gt 1GB } |
             Select-Object -First 1

    if ($found) {
        return $found.FullName
    }

    return $null
}

#==============================================================================
# STEP 4: Create Virtual Machines
#==============================================================================
Write-Host "`n[STEP 4] Creating virtual machines..." -ForegroundColor Yellow

$vmConfigs = @(
    @{ Name = 'hariskhurshidltd-dc';    RAM = 4GB; CPU = 2; SecureBoot = $true }
    @{ Name = 'hariskhurshidltdweb1';   RAM = 4GB; CPU = 2; SecureBoot = $true }
    @{ Name = 'hariskhurshidltdweb2';   RAM = 4GB; CPU = 2; SecureBoot = $true }
    @{ Name = 'hariskhurshidltdsql1';   RAM = 4GB; CPU = 2; SecureBoot = $true }
    @{ Name = 'hariskhurshidltdlinux1'; RAM = 2GB; CPU = 2; SecureBoot = $false }
)

foreach ($config in $vmConfigs) {
    $vmName = $config.Name
    Write-Host "`n  --- Creating: $vmName ---" -ForegroundColor Cyan

    # Check if VM already exists
    $existingVM = Get-VM -Name $vmName -ErrorAction SilentlyContinue
    if ($existingVM) {
        Write-Host "    VM already exists — skipping creation." -ForegroundColor Green
        continue
    }

    # Find VHDX
    $vhdxPath = Find-Vhdx -VMName $vmName
    if (-not $vhdxPath) {
        Write-Host "    ERROR: VHDX not found for $vmName!" -ForegroundColor Red
        continue
    }
    Write-Host "    Found VHDX: $vhdxPath" -ForegroundColor Green

    # Create VM (Generation 2, no VHD initially)
    New-VM -Name $vmName `
        -Generation 2 `
        -MemoryStartupBytes $config.RAM `
        -SwitchName "InternalNATSwitch" `
        -NoVHD

    # Add existing VHD
    Add-VMHardDiskDrive -VMName $vmName -Path $vhdxPath

    # Configure CPU
    Set-VM -Name $vmName `
        -ProcessorCount $config.CPU `
        -AutomaticStartAction Start `
        -AutomaticStopAction ShutDown `
        -AutomaticStartDelay 0

    # Set boot device to VHD
    $vhd = Get-VMHardDiskDrive -VMName $vmName | Select-Object -First 1
    Set-VMFirmware -VMName $vmName -FirstBootDevice $vhd

    # Configure Secure Boot
    if (-not $config.SecureBoot) {
        Set-VMFirmware -VMName $vmName -EnableSecureBoot Off
        Write-Host "    Secure Boot: OFF (Linux)" -ForegroundColor Yellow
    } else {
        Write-Host "    Secure Boot: ON" -ForegroundColor Green
    }

    Write-Host "    Created: $vmName ($($config.RAM/1GB)GB RAM, $($config.CPU) CPU)" -ForegroundColor Green
}

#==============================================================================
# STEP 5: Start VMs (DC First)
#==============================================================================
Write-Host "`n[STEP 5] Starting virtual machines..." -ForegroundColor Yellow

# Start Domain Controller first
Write-Host "  Starting hariskhurshidltd-dc (Domain Controller)..." -ForegroundColor Cyan
Start-VM -Name "hariskhurshidltd-dc" -ErrorAction SilentlyContinue
Write-Host "  Waiting 150 seconds for AD services to initialize..." -ForegroundColor White
Start-Sleep -Seconds 150

# Start remaining VMs
$otherVMs = @('hariskhurshidltdweb1', 'hariskhurshidltdweb2', 'hariskhurshidltdsql1', 'hariskhurshidltdlinux1')
foreach ($vm in $otherVMs) {
    Write-Host "  Starting $vm..." -ForegroundColor Cyan
    Start-VM -Name $vm -ErrorAction SilentlyContinue
}

Write-Host "  Waiting 60 seconds for all VMs to boot..." -ForegroundColor White
Start-Sleep -Seconds 60

#==============================================================================
# STEP 6: Print Status
#==============================================================================
Write-Host "`n[STEP 6] Final VM Status:" -ForegroundColor Yellow
Write-Host "  ================================================" -ForegroundColor White
Get-VM | Format-Table Name, State, CPUUsage, @{
    Label = 'MemoryGB'
    Expression = { [math]::Round($_.MemoryAssigned / 1GB, 1) }
}, Uptime -AutoSize | Out-String | Write-Host
Write-Host "  ================================================" -ForegroundColor White

#==============================================================================
# STEP 7: Cleanup Scheduled Task
#==============================================================================
Write-Host "`n[STEP 7] Cleaning up scheduled task..." -ForegroundColor Yellow
Unregister-ScheduledTask -TaskName "HarisKhurshidLTD-LabSetup" -Confirm:$false -ErrorAction SilentlyContinue
Write-Host "  Scheduled task removed." -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " LAB SETUP COMPLETE!" -ForegroundColor Green
Write-Host " Open Hyper-V Manager to see your VMs" -ForegroundColor Cyan
Write-Host " Website: http://192.168.100.20" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Stop-Transcript
