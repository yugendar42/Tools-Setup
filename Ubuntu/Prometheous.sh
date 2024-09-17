#!/bin/bash

# Update package list and clear the terminal
sudo apt-get update && clear

# Variables
PROMETHEUS_VERSION="2.43.0"
PROMETHEUS_TAR="prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
PROMETHEUS_URL="https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/${PROMETHEUS_TAR}"
PROMETHEUS_DIR="prometheus-${PROMETHEUS_VERSION}.linux-amd64"

# Download Prometheus tarball
wget $PROMETHEUS_URL

# Extract the tarball
tar xvzf $PROMETHEUS_TAR

# Remove the tarball after extraction
rm $PROMETHEUS_TAR

# Create a user for Prometheus (if it does not already exist)
if ! id "prometheus" &>/dev/null; then
    sudo useradd --no-create-home --shell /bin/false prometheus
fi

# Create necessary directories
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

# Move Prometheus binaries to /usr/local/bin
sudo mv $PROMETHEUS_DIR/prometheus /usr/local/bin/
sudo mv $PROMETHEUS_DIR/promtool /usr/local/bin/

# Move Prometheus configuration file to /etc/prometheus
sudo mv $PROMETHEUS_DIR/prometheus.yml /etc/prometheus/prometheus.yml

# Set ownership of the Prometheus directories and binaries
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus

# Create a systemd service file for Prometheus
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOL
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus/
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

# Update Prometheus configuration to add worker nodes
sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus_metrics'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter_metrics'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100', 'worker-1:9100', 'worker-2:9100']
EOF

# Reload systemd to pick up the new service file and enable service
sudo systemctl daemon-reload
sudo systemctl enable prometheus

# Start Prometheus service and check its status
sudo systemctl start prometheus
sudo systemctl status prometheus

echo "Prometheus installation and configuration completed successfully."
