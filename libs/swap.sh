#!/bin/bash

# Define swap file size and location
SWAPFILE=/swapfile
SWAPSIZE=2G

# Create a swap file
sudo fallocate -l $SWAPSIZE $SWAPFILE

# Set the correct permissions
sudo chmod 600 $SWAPFILE

# Set up a Linux swap area
sudo mkswap $SWAPFILE

# Enable the swap file
sudo swapon $SWAPFILE

# Make the swap file permanent
echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab

# Verify the swap is active
sudo swapon --show

# Display the current swap usage
free -h
