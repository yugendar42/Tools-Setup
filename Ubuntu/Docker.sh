#!/bin/bash

# This script automates Docker installation on Ubuntu 22

# Update the package list
echo "Updating package list..."
sudo apt-get update -y

# Remove any old Docker packages if installed
echo "Removing old Docker packages..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    sudo apt-get remove -y $pkg
done

# Install necessary packages for setting up Docker
echo "Installing necessary packages..."
sudo apt-get install -y ca-certificates curl

# Set up keyrings directory and add Docker’s official GPG key
echo "Setting up Docker's GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker’s official repository to the Apt sources list
echo "Adding Docker's repository to Apt sources..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package list again
echo "Updating package list with Docker repository..."
sudo apt-get update -y

# Install Docker packages
echo "Installing Docker components..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Create the docker group if it doesn't exist and add current user to the group
echo "Adding $USER to the docker group..."
sudo groupadd docker
sudo usermod -aG docker $USER

# Apply group changes (this will require logout/login to take effect)
echo "You need to log out and log back in for group changes to take effect."

# Check the status of Docker
echo "Checking Docker status..."
sudo systemctl status docker
