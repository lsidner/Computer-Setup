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
    "Clipchamp.Clipchamp",
    "Microsoft.Advertising.Xaml",
    "Microsoft.BingNews",
    "Microsoft.BingSearch",
    "Microsoft.BingWeather",
    "Microsoft.Copilot",
    "Microsoft.GamingApp",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.OneConnect",
    "Microsoft.OutlookForWindows",
    "Microsoft.People",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.StartExperiencesApp",
    "Microsoft.Todos",
    "Microsoft.Whiteboard",
    "Microsoft.Windows.DevHome",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "MSTeams"
)

# Remove bloatware apps
Write-Output "Removing bloatware applications..."
foreach ($app in $bloatware) {
    write-Output "Attempting to remove $app..."
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

Write-Output "Bloatware removal process completed."

#Remove OneDrive if installed
#Stop OneDrive process if running
Stop-Process -Name OneDrive -ErrorAction SilentlyContinue -Force

#Test for OneDrive and uninstall if found
if (Test-Path "$env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
    Start-Process -FilePath "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" -ArgumentList "/uninstall" -NoNewWindow -Wait
    } 
elseif (Test-Path "$env:SystemRoot\System32\OneDriveSetup.exe") {
    Start-Process -FilePath "$env:SystemRoot\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -NoNewWindow -Wait
    }

Write-Output "OneDrive removal process completed."

# Final message
Write-Output "Bloatware removal complete."

# Pause to allow user to see the output
Read-Host -Prompt "Press Enter to exit"