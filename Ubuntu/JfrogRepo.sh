#prerequisites for JFrog (https://jfrog.com/community/download-artifactory-oss/)
# medium instance t2 ytpe
#2cpus
#8081[ and 8082 and ssh ports and openjdk 11

# Update the package index
sudo apt update

# Install OpenJDK 11
sudo apt install -y default-jre

# Add JFrog GPG key
wget -qo - https://api.bintray.com/orgs/jfrog/keys/gpg/public.key | sudo apt-key add -

# Add JFrog repository to the apt sources list
echo "deb https://jfrog.bintray.com/artifactory-debs bionic main" | sudo tee /etc/apt/sources.list.d/jfrog.list

# Update package index again to include JFrog repository
sudo apt update

# Install JFrog Artifactory OSS
sudo apt install -y jfrog-artifactory-oss

# Start the JFrog Artifactory service and Enable the JFrog Artifactory service to start on boot
sudo systemctl start artifactory.service && sudo systemctl enable artifactory.service

# Check the status of the JFrog Artifactory service
sudo systemctl status artifactory.service
