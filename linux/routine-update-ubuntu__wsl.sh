
#!/bin/bash

# Ensure the script is run with sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script with sudo: sudo $0"
    exit 1
fi

# Detect WSL (the Microsoft kernel identifies itself in /proc/version)
IS_WSL=false
if grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
fi

echo "=========================================="
echo "🚀 Starting Ubuntu System Update Routine"
if $IS_WSL; then
    echo "   (WSL detected)"
fi
echo "=========================================="

# 1. Update the package lists from repositories
echo -e "\n🔄 1/6: Fetching latest package lists..."
apt-get update

# 2. Upgrade existing packages safely
echo -e "\n📦 2/6: Upgrading installed packages..."
apt-get upgrade -y

# 3. Perform a full/distribution upgrade
# (Handles changing dependencies, new kernel versions, etc.)
echo -e "\n🔄 3/6: Performing full/smart upgrade..."
apt-get dist-upgrade -y

# 4. Update Snap packages (Ubuntu uses Snap for apps like Firefox)
# Snap needs systemd as PID 1. On WSL that is only the case when
# systemd=true is set under [boot] in /etc/wsl.conf.
if ! command -v snap &> /dev/null; then
    echo -e "\n⏭️ 4/6: Snap not installed, skipping..."
elif [ ! -d /run/systemd/system ]; then
    echo -e "\n⏭️ 4/6: systemd is not running, so snapd is unavailable. Skipping Snap..."
else
    echo -e "\n⚡ 4/6: Updating Snap packages..."
    snap refresh
fi

# 5. Clean up unnecessary packages (old kernels, unused dependencies)
echo -e "\n🧹 5/6: Removing obsolete packages (autoremove)..."
apt-get autoremove -y

# 6. Clean up the package cache to free disk space
echo -e "\n🧽 6/6: Cleaning up package download cache..."
apt-get clean

echo -e "\n=========================================="
echo "✅ Ubuntu update routine complete!"
echo "=========================================="

if $IS_WSL; then
    # The WSL2 kernel ships with Windows, not apt, and 'reboot' does not
    # restart a WSL distro. Both are handled from the Windows side.
    echo "ℹ️  The WSL2 kernel is not updated by apt. To update it, run this"
    echo "    from PowerShell or CMD on Windows:  wsl --update"
    if [ -f /var/run/reboot-required ]; then
        echo "⚠️  Some updates need a restart of this distro to take effect."
        echo "    Close your WSL terminals, then run from PowerShell or CMD:"
        echo "      wsl --shutdown        (stops all WSL distros)"
        echo "    or, to restart only this one:"
        echo "      wsl --terminate <distro name from 'wsl -l'>"
    fi
else
    # Check if a system reboot is required
    if [ -f /var/run/reboot-required ]; then
        echo "⚠️  A reboot is required to finish applying some updates (like a new kernel)."
        read -p "Would you like to reboot now? (y/N): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            echo "🔄 Rebooting system..."
            reboot
        fi
    fi
fi
