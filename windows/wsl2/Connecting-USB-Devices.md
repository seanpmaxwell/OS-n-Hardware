# Connect USB devices
 
WSL can access USB devices through [usbipd-win](https://github.com/dorssel/usbipd-win). Install it on Windows first (for example with `winget install usbipd`).
 
### Step 1: Start the distro
 
The target WSL distro must be running before you attach a device:
 
```powershell
wsl -d <NewDistro>
```
 
### Step 2: Find the device's BUSID
 
Open PowerShell **as Administrator** and list connected USB devices:
 
```powershell
usbipd list
```
 
Example output:
 
```text
Connected:
BUSID  VID:PID    DEVICE                                         STATE
1-2    046d:c548  USB Input Device                               Not shared
1-4    0781:5583  USB Attached SCSI (UAS) Mass Storage Device    Not shared
1-7    0c45:6723  Integrated Webcam                              Not shared
```
 
Identify your device using the **DEVICE** description and the **VID** (vendor ID, the first half of `VID:PID`). For example, a USB flash drive usually appears as a "Mass Storage Device". Leave built-in devices such as your keyboard, mouse receiver, Bluetooth adapter, fingerprint reader and webcam alone.
 
### Step 3: Share and attach the device
 
```powershell
# Share the device (only needed once per device; requires Administrator)
usbipd bind --busid <BUSID>
 
# Attach it to the running WSL distro
usbipd attach --wsl --busid <BUSID>
```
 
### Step 4: Verify inside WSL
 
Inside the distro, confirm the device is visible:
 
```bash
lsusb
```
 
> If `lsusb` isn't found, install it with `sudo apt install usbutils`.
 
### Detaching
 
When you're done, detach the device so Windows can use it again:
 
```powershell
usbipd detach --busid <BUSID>
```
