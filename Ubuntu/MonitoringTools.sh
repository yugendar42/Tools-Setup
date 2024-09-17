#!/bin/bash

set -e  # Exit on any error

# Update and clear terminal
sudo apt update && clear

# --- Node Exporter Installation ---
NODE_EXPORTER_VERSION="1.8.2"
NODE_EXPORTER_TAR="node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
wget "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/${NODE_EXPORTER_TAR}"
tar xf $NODE_EXPORTER_TAR && rm $NODE_EXPORTER_TAR
sudo useradd -rs /bin/false node_exporter || true
sudo mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOL
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOL

# --- Prometheus Installation ---
PROMETHEUS_VERSION="2.43.0"
PROMETHEUS_TAR="prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
wget "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/${PROMETHEUS_TAR}"
tar xf $PROMETHEUS_TAR && rm $PROMETHEUS_TAR
sudo useradd --no-create-home --shell /bin/false prometheus || true
sudo mkdir -p /etc/prometheus /var/lib/prometheus /etc/prometheus/console_libraries /etc/prometheus/consoles
sudo mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /usr/local/bin/
sudo mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml
sudo mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/console_libraries/* /etc/prometheus/console_libraries/
sudo mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/consoles/* /etc/prometheus/consoles/
sudo chown -R prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool /etc/prometheus /var/lib/prometheus
rm -rf prometheus-${PROMETHEUS_VERSION}.linux-amd64
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOL
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOL

# --- Update Prometheus configuration with worker nodes ---
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
      - targets: ['localhost:9100', 'Tomcat:9100', 'Nexus:9100', 'Jfrog:9100', 'worker-1:9100', 'worker-2:9100']
EOF
#if any servers needs to watch go to vim /etc/hosts  add worker nodes puplic ip's and name of the server ex: 54.209.205.114 Tomcat
# --- Grafana Installation ---
sudo apt-get install -y apt-transport-https software-properties-common wget
wget -qO - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install -y grafana
sudo systemctl enable grafana-server

# Reload systemd to pick up new services
sudo systemctl daemon-reload

# Enable and start Node Exporter, Prometheus, and Grafana services
echo "Starting services..."
sudo systemctl enable --now node_exporter
sudo systemctl enable --now prometheus
sudo systemctl enable --now grafana-server

# Check the status of each service
echo "Checking the status of Node Exporter, Prometheus, and Grafana:"
echo "------------------------------------------------------------"
sudo systemctl status node_exporter
echo "------------------------------------------------------------"
sudo systemctl status prometheus
echo "------------------------------------------------------------"
sudo systemctl status grafana-server

echo "Node Exporter, Prometheus, and Grafana installation and setup completed successfully."
