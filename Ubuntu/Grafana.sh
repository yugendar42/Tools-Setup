#!/bin/bash

# Install prerequisite packages
sudo apt-get update
sudo apt-get install -y apt-transport-https software-properties-common wget

# Import the GPG key for the Grafana APT repository
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

# Add the Grafana APT repository for stable releases
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Optionally, add the Grafana APT repository for beta releases
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com beta main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Update the list of available packages
sudo apt-get update

# Install Grafana OSS
echo "Installing Grafana OSS..."
sudo apt-get install -y grafana

# Start and enable Grafana service
sudo systemctl enable grafana-server && sudo systemctl start grafana-server

# Check the status of the Grafana service
sudo systemctl status grafana-server
