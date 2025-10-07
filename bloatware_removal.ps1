<#
.SYNOPSIS
    This script removes common bloatware applications from a Windows installation.
.DESCRIPTION
    This script identifies and removes pre-installed applications that are often considered unnecessary.
    It requires administrative privileges to run and will prompt for elevation if not executed as an administrator.
.EXAMPLE
    .\bloatware_removal.ps1
    Runs the script to remove bloatware applications from the current Windows installation.
.NOTES
    Run this script with caution. Removing certain applications may affect system functionality or user experience.
    Always ensure you have backups of important data before running scripts that modify system settings or applications.
    Tested on Windows 10 and Windows 11.
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
Write-Output "Starting bloatware removal script..."

# List of bloatware apps to remove
$bloatware = @(
    "Clipchamp.Clipchamp",
    "Microsoft.3DViewer",
    "Microsoft.Microsoft3DViewer", # 3D Viewer (alternate name)
    "Microsoft.549981C3F5F10", # Cortana
    "Microsoft.Advertising.Xaml",
    "Microsoft.BingNews",
    "Microsoft.BingSearch",
    "Microsoft.BingWeather",
    "Microsoft.Copilot",
    "Microsoft.GamingApp",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.MicrosoftJournal",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MinecraftEducationEdition",
    "Microsoft.MixedReality.Portal",
    "Microsoft.Office.OneNote",
    "Microsoft.OneConnect",
    "Microsoft.OutlookForWindows",
    "Microsoft.People",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.SkypeApp",
    "Microsoft.StartExperiencesApp", # News and Interests
    "Microsoft.Todos",
    "Microsoft.Wallet",
    "Microsoft.Whiteboard",
    "Microsoft.Windows.DevHome",
    "Microsoft.WindowsAlarms",
    "microsoft.windowscommunicationsapps", # Mail and Calendar
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic", # Movies & TV
    "Microsoft.ZuneVideo", # Groove Music
    "MicrosoftCorportationII.MicrosoftFamily",
    "MicrosoftCorporationII.QuickAssist",
    "MicrosoftTeams", # Microsoft Teams (work or school version)
    "MSTeams" # Microsoft Teams (personal version)
)

# Remove bloatware apps
Write-Output "Removing bloatware applications..."
foreach ($app in $bloatware) {
    write-Output "Attempting to remove $app..."
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

Write-Output "Bloatware removal process completed."

<#
These next lines will remove OneDrive, which is often considered bloatware on Windows systems.
Note: Removing OneDrive may affect file synchronization for users who rely on it.
#>

#Stop OneDrive process if running
Stop-Process -Name OneDrive -ErrorAction SilentlyContinue -Force

#Test for OneDrive and uninstall if found
if (Test-Path "$env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
    Start-Process -FilePath "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" -ArgumentList "/uninstall" -NoNewWindow -Wait
    } 
elseif (Test-Path "$env:SystemRoot\System32\OneDriveSetup.exe") {
    Start-Process -FilePath "$env:SystemRoot\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -NoNewWindow -Wait
    }
else {
    Write-Output "OneDriveSetup.exe not found. OneDrive may not be installed."
}

Write-Output "OneDrive removal process completed."

# OneDrive cleanup
Write-Output "Cleaning up OneDrive remnants..."
$OneDrivePaths = @(
    "$env:UserProfile\OneDrive",
    "$env:LocalAppData\Microsoft\OneDrive",
    "$env:ProgramData\Microsoft OneDrive",
    "$env:UserProfile\AppData\Local\Microsoft\OneDrive",
    "$env:UserProfile\AppData\Roaming\Microsoft\OneDrive"
)
foreach ($path in $OneDrivePaths) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Output "Removed $path"
    }
}
Write-Output "OneDrive cleanup completed."

# Final message
Write-Output "Bloatware removal complete."

# Pause to allow user to see the output
Read-Host -Prompt "Press Enter to exit"