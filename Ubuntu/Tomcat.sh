#!/bin/bash

# Exit script on any command failure
#set -e

# Clear the terminal
clear

# Update package list and install OpenJDK 11
echo "Updating package list and installing OpenJDK 11..."
sudo apt update
sudo apt install -y openjdk-11-jdk

# Create Tomcat user
echo "Creating Tomcat user..."
sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat

# Download Tomcat
echo "Downloading Tomcat..."
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.93/bin/apache-tomcat-9.0.93.tar.gz

# Extract Tomcat tarball
echo "Extracting Tomcat tarball..."
tar xzf apache-tomcat-9.0.93.tar.gz

# Create the Tomcat installation directory
echo "Creating Tomcat installation directory..."
sudo mkdir -p /opt/tomcat

# Move the extracted Tomcat files to /opt/tomcat
echo "Moving Tomcat files to /opt/tomcat..."
sudo mv apache-tomcat-9.0.93/* /opt/tomcat/

# Clean up the tarball and the extracted directory
echo "Cleaning up..."
rm apache-tomcat-9.0.93.tar.gz
rm -rf apache-tomcat-9.0.93

# Set ownership of the Tomcat directory
echo "Setting ownership of Tomcat directory..."
sudo chown -R tomcat:tomcat /opt/tomcat/

# Configure Tomcat
echo "Configuring Tomcat..."
sudo mkdir -p /opt/tomcat/conf/Catalina/localhost

# Create and configure manager.xml
sudo bash -c 'cat > /opt/tomcat/conf/Catalina/localhost/manager.xml <<EOF
<Context privileged="true" antiResourceLocking="false" docBase="\${catalina.home}/webapps/manager">
    <Valve className="org.apache.catalina.valves.RemoteAddrValve" allow="^.*$" />
</Context>
EOF'

# Create and configure host-manager.xml
sudo bash -c 'cat > /opt/tomcat/conf/Catalina/localhost/host-manager.xml <<EOF
<Context privileged="true" antiResourceLocking="false" docBase="\${catalina.home}/webapps/host-manager">
    <Valve className="org.apache.catalina.valves.RemoteAddrValve" allow="^.*$" />
</Context>
EOF'

# Modify tomcat-users.xml to add user details
echo "Modifying tomcat-users.xml..."
sudo sed -i '56 a\<role rolename="manager-gui"/>' /opt/tomcat/conf/tomcat-users.xml
sudo sed -i '57 a\<role rolename="manager-script"/>' /opt/tomcat/conf/tomcat-users.xml
sudo sed -i '58 a\<user username="yugendar" password="yugendar@123" roles="manager-gui, manager-script"/>' /opt/tomcat/conf/tomcat-users.xml
sudo sed -i '59 a\</tomcat-users>' /opt/tomcat/conf/tomcat-users.xml
sudo sed -i '56d' /opt/tomcat/conf/tomcat-users.xml

# Create Tomcat service file
echo "Creating Tomcat service file..."
sudo bash -c 'cat > /etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Tomcat
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd and start Tomcat service
echo "Reloading systemd and starting Tomcat service..."
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat

# Check Tomcat status
echo "Checking Tomcat status..."
sudo systemctl status tomcat
