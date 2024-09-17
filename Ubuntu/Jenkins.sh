#step1: Install java
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

#step2: Add Jenkins Repository
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key


#step3: Add a Jenkins apt repository entry
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null


#step4:Install Jenkins on ubuntu 22.04
sudo apt-get update
sudo apt-get install jenkins -y

#step5:Start and Enable Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins
systemctl status jenkins
