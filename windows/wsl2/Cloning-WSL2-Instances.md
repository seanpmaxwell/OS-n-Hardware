# Cloning a WSL Distro
 
This guide shows how to make an independent copy of an existing WSL distribution, give the copy its own hostname and default user, and pass USB devices through to it.
 
---
 
## 1. Clone a distro
 
You clone a distro by exporting it to a file and importing that file under a new name. Run these commands in **PowerShell** on Windows.
 
```powershell
# List installed distros and note the exact name of the one to copy
wsl -l -v
 
# Stop the source distro so the export is consistent
wsl --terminate <SourceDistro>
 
# Export it to a tar file
wsl --export <SourceDistro> C:\WSL\backup.tar
 
# Import it under a new name, with its own install folder
wsl --import <NewDistro> C:\WSL\<NewDistro> C:\WSL\backup.tar
 
# Launch the clone
wsl -d <NewDistro>
```
 
> **Note:** Make sure the `C:\WSL` folder exists before exporting, or choose another location.
 
### Faster option: export as a virtual disk
 
On recent WSL versions you can skip the tar archive and copy the virtual disk directly. This is usually much faster for large distros:
 
```powershell
wsl --export <SourceDistro> C:\WSL\backup.vhdx --format vhd
wsl --import <NewDistro> C:\WSL\<NewDistro> C:\WSL\backup.vhdx --vhd
```
 
### After cloning
 
- The clone is fully independent: changes in one distro don't affect the other.
- Once the clone works, you can delete the `.tar` / `.vhdx` file or keep it as a backup.
---
 
## 2. Set the default user
 
Imported distros log in as `root` by default. To log in as your normal user instead, open `/etc/wsl.conf` inside the clone:
 
```bash
sudo nano /etc/wsl.conf
```
 
Add (or update) the `[user]` section:
 
```ini
[user]
default=<username>
```
 
Save the file, then restart the distro from PowerShell so the change takes effect:
 
```powershell
wsl --terminate <NewDistro>
wsl -d <NewDistro>
```
 
---
 
## 3. Change the hostname
 
By default, every WSL distro uses your Windows computer's name as its hostname. You can override this per distro in the same `/etc/wsl.conf` file.
 
Add a `[network]` section alongside the existing `[user]` section:
 
```ini
[user]
default=<username>
 
[network]
hostname=<new-hostname>
```
 
Save the file and restart the distro:
 
```powershell
wsl --terminate <NewDistro>
wsl -d <NewDistro>
```
 
---
 
## 4. Change the user's password
 
The clone keeps the same password as the source distro. To change it, run this in PowerShell:
 
```powershell
wsl -d <NewDistro> -u root passwd <username>
```
