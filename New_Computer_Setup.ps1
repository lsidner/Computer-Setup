<#
.SYNOPSIS
    This script automates the setup of a new computer with essential software and configurations.

.DESCRIPTION
    This script installs common applications, configures system settings, and applies user preferences.
    It prompts for user input where necessary and provides a summary of actions taken.
    Ensure to run this script with administrative privileges.

.PARAMETER NewComputerName
    The new name for the computer.

.PARAMETER DomainName
    The domain to join the computer to.

.PARAMETER DomainGroup
    The domain group to add to the local Administrators group.

.EXAMPLE
    .\New_Computer_Setup.ps1
#>

# Self-elevate if not running as admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Starting new computer setup script..." -ForegroundColor Green

#Change computer name and join domain (modify as needed)
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

Write-Host "Computer renamed to $NewComputerName and joined to domain $DomainName. A restart is required." -ForegroundColor Green

# Configure domain group to local Administrators group (uncomment and modify as needed)
$DomainGroup = Read-Host "`nEnter the domain group to add to local Administrators (e.g. CONTOSO\Admins)"
Add-LocalGroupMember -Group "Administrators" -Member $DomainGroup
Write-Host "Added $DomainGroup to local Administrators group." -ForegroundColor Green

<#
List of applications to install (via Chocolatey)
Modify this list to include/exclude applications as needed.
#>
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

#Remove chocolatey afterwards if no longer needed (optional)
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

<#
Example: Enable dark mode for system
Changes registry settings to enable dark mode
Note: This affects system theme; individual apps may have separate settings.
#>
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0

# Example: Set time zone (EST)
tzutil /s "Eastern Standard Time"  # Change as needed

# Example: Disable unnecessary startup programs (modify as needed)
processes = @("msedge.exe", "terminal.exe")  # Add more process names as needed
foreach ($process in $processes) {
     Get-CimInstance -ClassName Win32_StartupCommand | Where-Object { $_.Name -like "*$process*" } | Remove-CimInstance
}

# Example: Set Chrome as default browser (from chocolatey install)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name "ProgId" -Value "ChromeHTML"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -Name "ProgId" -Value "ChromeHTML"


# Summary of actions taken
Write-Host "`nSetup Summary:" -ForegroundColor Yellow
Write-Host "Computer Name: $NewComputerName" -ForegroundColor Green
Write-Host "Domain Joined: $DomainName" -ForegroundColor Green
Write-Host "Installed Applications:" -ForegroundColor Yellow
$apps | ForEach-Object { Write-Host "- $_" -ForegroundColor Green }
Write-Host "System settings configured." -ForegroundColor Green
Write-Host "`nSetup complete! Please restart your computer to apply all changes." -ForegroundColor Green

# Wait for user input before closing
Read-Host -Prompt "Press Enter to close this window"