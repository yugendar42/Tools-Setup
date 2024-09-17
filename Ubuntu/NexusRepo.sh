#Execute below commands in t2-medium ubuntu server 22 lts, enable inbound rule with port number 8081

#!/bin/bash

# Update the package list
sudo apt-get update -y

# Install necessary packages
sudo apt-get install wget -y
sudo apt-get install openjdk-8-jdk -y

# Create the application directory
sudo mkdir -p /app && cd /app

# Download Nexus Repository
sudo wget -O nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz

# Extract the downloaded tar.gz file
sudo tar -xvf nexus.tar.gz

# Rename the extracted folder to 'nexus'
sudo mv nexus-3* nexus

# Create a dedicated nexus user
sudo adduser --system --no-create-home --group nexus

# Change ownership of the Nexus and sonatype-work directories
sudo chown -R nexus:nexus /app/nexus
sudo chown -R nexus:nexus /app/sonatype-work

# Configure Nexus to run as the nexus user
echo "run_as_user=\"nexus\"" | sudo tee /app/nexus/bin/nexus.rc

# Create a systemd service file for Nexus
sudo tee /etc/systemd/system/nexus.service > /dev/null << EOL
[Unit]
Description=Nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/app/nexus/bin/nexus start
ExecStop=/app/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the Nexus service
sudo systemctl enable nexus
sudo systemctl start nexus

# Check the status of the Nexus service
sudo systemctl status nexus
