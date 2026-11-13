# Remove Windows11 bloat

## Basic Uninstalls
- CoPilot
- Microsoft To Do
- Sticky Notes
- Clipchamp
- Microsoft Movie Maker (if it's there)
- Outlook (new)
- Microsoft Teams
- Microsoft Office 365 (if it's there)
- Feedback Hub (sending diagnostics to Microsoft)
- Power Automate (automating workflows in Windows)
- Microsoft Family Safety (aka Family)
- Quick Assist (for remote troubleshooting, is a security vulnerability)
- Maps

## Purge OneDrive

### Unlink OneDrive from Windows 11
To unlink OneDrive from Windows 11, you can do this directly through the OneDrive settings menu. This stops OneDrive from syncing your files while keeping your local and cloud files safe.

Here are the step-by-step instructions:

1. **Open OneDrive Settings:** System Tray.
Look at your taskbar in the bottom-right corner (the system tray). Click the **Show hidden icons** arrow (the small upward caret), then click the **OneDrive** cloud icon.
*Verification:* The OneDrive popup menu appears on your screen.


2. **Access Account Settings:** Gear Icon.
Click the **Help & Settings** gear icon in the top-right corner of the OneDrive popup, then select **Settings** from the drop-down menu.
*Verification:* The OneDrive Settings window opens on your screen.


3. **Unlink the PC:** Accounts Tab.
In the left-hand sidebar, click on the **Account** tab. Under your account name, click the blue **Unlink this PC** link.
*Verification:* A confirmation prompt appears asking if you want to unlink your account.


4. **Confirm Unlinking:** Final Step.
Click **Unlink account** in the confirmation box.
*Verification:* The OneDrive setup screen appears, confirming that your account is no longer linked to this computer. You can now close out of the window.

---


### Change pointers

```powershell
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'

# Backup first
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" "$env:USERPROFILE\ShellFolders-backup.reg" /y

$item = Get-Item $key
foreach ($name in $item.GetValueNames()) {
    $value = $item.GetValue($name, $null, 'DoNotExpandEnvironmentNames')
    Write-Host "$name = $value"
    if ($value -match '\\OneDrive[^\\]*\\(.+)$') {
        $new = "%USERPROFILE%\$($Matches[1])"
        $expanded = [Environment]::ExpandEnvironmentVariables($new)
        if (-not (Test-Path $expanded)) { New-Item -ItemType Directory -Path $expanded | Out-Null }
        Set-ItemProperty -Path $key -Name $name -Value $new -Type ExpandString
        Write-Host "   -> changed to $new" -ForegroundColor Green
    }
}

# Restart Explorer so the change takes effect
Stop-Process -Name explorer -Force
```

#### Move files

```powershell
robocopy "C:\Users\spmax\OneDrive\Documents" "C:\Users\spmax\Documents" /E /MOVE
robocopy "C:\Users\spmax\OneDrive\Desktop"   "C:\Users\spmax\Desktop"   /E /MOVE
robocopy "C:\Users\spmax\OneDrive\Pictures"  "C:\Users\spmax\Pictures"  /E /MOVE
```
