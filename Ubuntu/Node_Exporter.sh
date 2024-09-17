#!/bin/bash

# Clear the terminal screen
sudo apt update && clear

# Download the Node Exporter tarball
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

# Extract the tarball
tar xvzf node_exporter-1.8.2.linux-amd64.tar.gz

# Remove the tarball after extraction
rm node_exporter-1.8.2.linux-amd64.tar.gz

# Create a new user for Node Exporter (if it does not already exist)
if ! id "node_exporter" &>/dev/null; then
    sudo useradd -rs /bin/false node_exporter
fi

# Move the Node Exporter binary to /usr/local/bin
sudo mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/

# Set ownership for the Node Exporter binary
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Remove the extracted directory after moving the binary
rm -rf node_exporter-1.8.2.linux-amd64

# Create a systemd service file for Node Exporter
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOL
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd to pick up the new service file
sudo systemctl daemon-reload && sudo systemctl enable node_exporter

# Start the Node Exporter service and check its status
sudo systemctl start node_exporter && sudo systemctl status node_exporter
