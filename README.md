## Computer-Setup

Collection of PowerShell scripts to automate initial setup of a new Windows computer and remove common pre-installed "bloatware" applications. These are example scripts intended for IT use and testing. Review and adapt them to your environment before running. Each script can run independently of each other.

### Contents

- `New_Computer_Setup.ps1` — Automates common post-imaging tasks: rename computer, join a domain, add a domain group to local Administrators, install applications via Chocolatey, configure a few system settings, and print a summary. Prompts for input where required.
- `bloatware_removal.ps1` — Removes a set of pre-installed Microsoft Store apps and (optionally) OneDrive. Requires administrative privileges.

## Quick start

1. Open PowerShell as Administrator.
2. (Optional) Set execution policy for the current session and run the script you want.

To run the bloatware removal script:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\bloatware_removal.ps1
```

To run the new computer setup script:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\New_Computer_Setup.ps1
```

Note: Both scripts attempt to self-elevate when not run as Administrator. Still, running PowerShell as Administrator before invoking them avoids an extra elevation prompt.

## Requirements and assumptions

- Windows 10 / 11 (or Windows Server where Get-AppxPackage / Get-AppxProvisionedPackage are relevant).
- Administrative privileges (scripts will attempt to elevate).
- Internet access to install Chocolatey and packages (for `New_Computer_Setup.ps1`).
- Chocolatey is installed by the setup script if missing. You can skip that step if you prefer to manage Chocolatey separately.

## What the scripts do (high level)

`bloatware_removal.ps1`:
- Contains a list of Appx packages to remove (examples: Clipchamp, GetHelp, Xbox components, Solitaire, Feedback Hub).
- Calls `Get-AppxPackage` and `Remove-AppxPackage` to remove the packages for the current user and `Get-AppxProvisionedPackage` / `Remove-AppxProvisionedPackage -Online` to remove provisioned packages.
- Checks for OneDrive at `%SystemRoot%\SysWOW64\OneDriveSetup.exe`, `%SystemRoot%\System32\OneDriveSetup.exe`, and will run the uninstall switch if present.

`New_Computer_Setup.ps1`:
- Prompts for a new computer name and a domain to join. Calls `Rename-Computer` and `Add-Computer` (will prompt for credentials and may require a restart).
- Prompts for a domain group to add to the local `Administrators` group and calls `Add-LocalGroupMember`.
- Installs Chocolatey (if missing) and then installs a list of apps defined in the `$apps` array (`googlechrome`, `keepass`, `googledrive` by default).
- Configures a few example system settings: power plan, disables hibernation, sets time zone.

## Customization

- Edit the list of bloatware in `bloatware_removal.ps1` (`$bloatware` array) to add/remove applications you want to target.
- In `New_Computer_Setup.ps1` change the `$apps` array to include the Chocolatey packages you want installed.
- Uncomment or modify additional sections (e.g., wallpaper, chocolatey uninstall) as needed. Lines that are intentionally commented are labeled in the script.
- Change timezone in the `tzutil /s "Eastern Standard Time"` line to your preferred timezone.

## Safety and recommended workflow

1. Always review scripts before running. These scripts make system-level changes (rename, domain join, package removal, uninstallers).
2. Test in a virtual machine or a non-production device first.
3. Backup important data and create a system restore point or image before mass changes.
4. When joining a domain, be certain you have appropriate domain admin credentials and that a restart is acceptable.

## Common troubleshooting

- Chocolatey install fails: check network/proxy settings and ensure TLS 1.2 is available. The script enables TLS 1.2 when invoking the installer.
- Appx packages not found: some packages are not installed for every image or may have different package names. Adjust the `$bloatware` array or run `Get-AppxPackage -AllUsers` to inspect installed packages.
- OneDrive uninstall not found: the script looks for `%SystemRoot%\SysWOW64\OneDriveSetup.exe` and `%SystemRoot%\System32\OneDriveSetup.exe`; OneDrive may be located elsewhere.

## Notes and disclaimers

These scripts are provided as examples and are intended for use by system administrators. Use at your own risk. The author(s) are not responsible for data loss or system misconfiguration caused by these scripts.

## License

No license specified.

---
<!--
Last updated: Automatically updated on save by Visual Studio Code using configured "Run on Save" or a save hook.
Do not edit this line manually.
-->

**Last Updated:** 2025-10-06 10:45 AM
