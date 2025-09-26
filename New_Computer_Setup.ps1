<#
.SYNOPSIS
    This script automates the setup of a new computer with essential software and configurations.

.DESCRIPTION
    This script installs common applications, configures system settings, and applies user preferences.
    It prompts for user input where necessary and provides a summary of actions taken.
    Ensure to run this script with administrative privileges.
#>

# Self-elevate if not running as admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Starting new computer setup script..." -ForegroundColor Green

#Change computer name and join domain (uncomment and modify as needed)
Read-Host "`nNote: Changing the computer name and joining a domain requires a restart. Please save your work."
$NewComputerName = Read-Host "`nEnter a new computer name (e.g. Workstation01)"
if ([string]::IsNullOrWhiteSpace($NewComputerName)) {
    Write-Error "Computer name cannot be empty. Exiting."
    exit 1
}

$DomainName = Read-Host "Enter the domain to join (e.g. corp.contoso.com)"
if ([string]::IsNullOrWhiteSpace($DomainName)) {
    Write-Error "Domain name cannot be empty. Exiting."
    exit 1
}

Rename-Computer -NewName $NewComputerName

Add-Computer -DomainName $DomainName -Credential (Get-Credential)

Write-Host "Computer renamed to $NewComputerName and joined to domain corp.contoso.com. A restart is required." -ForegroundColor Green

#Add LocalPCAdmins group to local Administrators group (uncomment and modify as needed)
Add-LocalGroupMember -Group "Administrators" -Member "SIMPLAY3\LocalPCAdmins"
Write-Host "Added LocalPCAdmins to local Administrators group." -ForegroundColor Green

# List of applications to install (via Chocolatey)
# Modify this list to include/exclude applications as needed
$apps = @(
    "googlechrome",
    "keepass",
    "googledrive"
)

# Install Chocolatey if not already installed
# Chocolatey is a package manager for Windows (https://chocolatey.org/)
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install applications using Chocolatey
Write-Host "Installing applications..." -ForegroundColor Yellow
foreach ($app in $apps) {
    Write-Host "Installing $app..." -ForegroundColor Cyan
    choco install $app -y
}

# Remove bloatware (uncomment and modify as needed)


#Remove chocolatey afterwards (optional)
# choco uninstall chocolatey -y

# Configure system settings
Write-Host "Configuring system settings..." -ForegroundColor Yellow

# Example: Set power plan to High Performance
powercfg -setactive SCHEME_MIN  # High Performance

# Example: Disable hibernation
powercfg -h off

# Example: Set desktop background (uncomment and specify path)
# $WallpaperPath = "C:\Path\To\Your\Wallpaper.jpg"
# Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name Wallpaper -Value $WallpaperPath
# RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

# Example: Set time zone
tzutil /s "Eastern Standard Time"  # Change as needed

# Summary of actions taken
Write-Host "`nSetup Summary:" -ForegroundColor Yellow
Write-Host "Installed Applications:" -ForegroundColor Yellow
$apps | ForEach-Object { Write-Host "- $_" -ForegroundColor Green }
Write-Host "System settings configured." -ForegroundColor Green
Write-Host "`nSetup complete! Please restart your computer to apply all changes." -ForegroundColor Green
Read-Host -Prompt "Press Enter to exit"