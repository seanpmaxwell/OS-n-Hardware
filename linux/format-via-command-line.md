
### RUN THIS IN POWERSHELL: First make sure USBs are connected to WSL (might not be 1-17)
```sh
usbipd bind --busid 1-17
usbipd attach --wsl --busid 1-17
```

### Check the drive name (In WSL)

```sh
lsblk -d -o NAME,SIZE,MODEL,TRAN
```

### Run the script (replace the X in /dev/sdX with your drive letter)
```bash
DEV=/dev/sdX
[ "$(lsblk -dno TRAN "$DEV")" = usb ] || { echo "Not a USB disk — stopping"; exit 1; }
sudo apt install -y exfatprogs parted
for p in ${DEV}?*; do sudo umount "$p" 2>/dev/null; done
sudo wipefs -a "$DEV"
sudo parted -s "$DEV" mklabel msdos mkpart primary 1MiB 100%
sudo partprobe "$DEV"; sleep 1
sudo mkfs.exfat -n USB "${DEV}1"
lsblk -o NAME,SIZE,FSTYPE,LABEL "$DEV"
```

### Release the thumb drive (Back in powershell)
```sh
usbipd list
usbipd unbind --busid 1-17
```
