### Change how it's displayed

Settings -> General -> About -> Edit name field -> hit "Tab"

### Change it at the hardware level

```bash
sudo scutil --set ComputerName "MyNewMac"
sudo scutil --set HostName "MyNewMac"
sudo scutil --set LocalHostName "MyNewMac"
```

### Verify changes

```bash
scutil --get ComputerName              
scutil --get HostName
scutil --get LocalHostName
```
