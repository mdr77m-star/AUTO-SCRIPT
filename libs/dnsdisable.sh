#!/bin/bash

# Stop systemd-resolved service
sudo systemctl stop systemd-resolved

# Disable systemd-resolved from starting at boot
sudo systemctl disable systemd-resolved
cp /etc/resolv.conf resolv.bak
# Remove the existing symlinked resolv.conf
sudo rm /etc/resolv.conf

# Create a new resolv.conf file with custom DNS entries
echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" | sudo tee /etc/resolv.conf > /dev/null

echo "systemd-resolved is disabled, and a new resolv.conf has been created."
