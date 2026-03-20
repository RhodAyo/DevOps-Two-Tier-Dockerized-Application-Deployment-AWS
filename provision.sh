#!/bin/bash  //run this script using bash

# Exit script if any command fails
set -e

echo "Provisioning script to automate setup for EC2 Instance with Docker and EBS volume for MySQL data storage."
echo "Starting provisioning..."

# 1. Update system packages
echo "Updating system packages..."
sudo apt update -y

# 2. Install Docker (if not installed)
if ! command -v docker &> /dev/null
then
    echo "Installing Docker..."
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "Docker already installed!"
fi

# 3. Install Docker Compose (if not installed)
if ! command -v docker-compose &> /dev/null
then
    echo "Installing Docker Compose..."
    sudo apt install -y docker-compose
else
    echo "Docker Compose already installed!"
fi

# 4. Create application directories
echo "Creating application directories..."
sudo mkdir -p /mnt/mysql-data

# 5. Check if EBS volume exists and mount it
if lsblk | grep -q "nvme1n1"; then
    echo "EBS volume found..."

    # Format if not already formatted
    if ! blkid /dev/nvme1n1; then
        echo "Formatting EBS volume..."
        sudo mkfs -t ext4 /dev/nvme1n1
    else
        echo "EBS volume already formatted!"
    fi

    # Mount if not already mounted
    if ! mount | grep -q "/mnt/mysql-data"; then
        echo "Mounting volume..."
        sudo mount /dev/nvme1n1 /mnt/mysql-data
    else
        echo "Volume already mounted!"
    fi
else
    echo "EBS volume not found!"
fi

# 6. Set permissions for Docker to use the directory
echo "Setting permissions..."
sudo chown -R ubuntu:ubuntu /mnt/mysql-data
sudo chmod -R 755 /mnt/mysql-data

echo "Provisioning complete!"