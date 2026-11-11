#!/bin/bash

# Ensure the script is run with sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script with sudo: sudo $0"
    exit 1
fi

echo "=========================================="
echo "🚀 Starting Ubuntu System Update Routine"
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
if command -v snap &> /dev/null; then
    echo -e "\n⚡ 4/6: Updating Snap packages..."
    snap refresh
else
    echo -e "\n⏭️ 4/6: Snap not installed, skipping..."
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

# Check if a system reboot is required
if [ -f /var/run/reboot-required ]; then
    echo "⚠️  A reboot is required to finish applying some updates (like a new kernel)."
    read -p "Would you like to reboot now? (y/N): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        echo "🔄 Rebooting system..."
        reboot
    fi
fi
