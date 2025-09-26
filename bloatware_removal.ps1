<#
.SYNOPSIS
    This script removes common bloatware applications from a Windows installation.
.DESCRIPTION
    This script identifies and removes pre-installed applications that are often considered unnecessary.
    It requires administrative privileges to run and will prompt for elevation if not executed as an administrator.
#>

#Elevate to run as administrator if not already
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "Script is not running as administrator. Attempting to restart with elevated privileges..."
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
} else {
    Write-Output "Script is running with administrative privileges."
}

# Start of the script
Write-Output "Starting bloatware removal script..." -ForegroundColor Green

# List of bloatware apps to remove
$bloatware = @(
    "Microsoft.Clipchamp",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.SolitaireCollection",
    "Microsoft.OutlookForWindows",
    "Microsoft.FeedbackHub",
    "Microsoft.Xbox*"
)

# Remove bloatware apps
Write-Output "Removing bloatware applications..."
foreach ($app in $bloatware) {
    Get-AppxPackage -Name $app | Remove-AppxPackage
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $app | Remove-AppxProvisionedPackage -Online
    #show message for each app removed or not found
    if ($?) {
        Write-Output "Removed $app"
    } else {
        Write-Output "$app not found or could not be removed"
    }
}

#Remove OneDrive if installed
Write-Output "Checking for OneDrive installation..."
$oneDrivePath = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
if (Test-Path $oneDrivePath) {
    Write-Output "OneDrive found. Uninstalling..."
    Start-Process $oneDrivePath "/uninstall" -NoNewWindow -Wait
    Write-Output "OneDrive uninstalled."
} else {
    Write-Output "OneDrive not found."
}

# Final message
Write-Output "Bloatware removal complete."

# Pause to allow user to see the output
Read-Host -Prompt "Press Enter to exit"