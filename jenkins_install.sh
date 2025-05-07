#!/bin/bash
#
# Jenkins Installation Script for Google Cloud Console
# This script installs Jenkins on Linux and configures the necessary firewall settings.
#

# Exit on any error
set -e

# Print commands being executed
set -x

# Colors for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Jenkins installation...${NC}"

# Update system packages
echo -e "${YELLOW}Updating system packages...${NC}"
sudo apt-get update -y

# Install Java (required for Jenkins)
echo -e "${YELLOW}Installing Java...${NC}"
sudo apt-get install -y openjdk-11-jdk

# Verify Java installation
java -version

# Add Jenkins repository key
echo -e "${YELLOW}Adding Jenkins repository...${NC}"
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package lists with Jenkins repository
sudo apt-get update -y

# Install Jenkins
echo -e "${YELLOW}Installing Jenkins...${NC}"
sudo apt-get install -y jenkins

# Start Jenkins service
echo -e "${YELLOW}Starting Jenkins service...${NC}"
sudo systemctl start jenkins

# Enable Jenkins to start at boot
sudo systemctl enable jenkins

# Check if Jenkins is running
if sudo systemctl status jenkins | grep -q "active (running)"; then
    echo -e "${GREEN}Jenkins is running successfully!${NC}"
else
    echo -e "${RED}Jenkins installation failed. Please check the logs.${NC}"
    exit 1
fi

# Configure firewall for Jenkins
echo -e "${YELLOW}Configuring firewall for Jenkins...${NC}"

# Check if ufw is installed, if not install it
if ! command -v ufw &> /dev/null; then
    echo -e "${YELLOW}Installing UFW firewall...${NC}"
    sudo apt-get install -y ufw
fi

# Configure ufw
sudo ufw allow OpenSSH
sudo ufw allow 8080/tcp
sudo ufw --force enable

# Install additional useful tools
echo -e "${YELLOW}Installing additional tools...${NC}"
sudo apt-get install -y git curl wget unzip zip

# Configure Google Cloud Firewall
echo -e "${YELLOW}Note: You need to configure Google Cloud Firewall manually.${NC}"
echo -e "${YELLOW}See instructions in the accompanying documentation.${NC}"

# Get the initial admin password
echo -e "${YELLOW}Retrieving initial admin password...${NC}"
echo -e "${GREEN}Jenkins initial admin password:${NC}"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Get the VM's external IP address
EXTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}Jenkins installation complete!${NC}"
echo -e "${GREEN}You can access Jenkins at: http://$EXTERNAL_IP:8080${NC}"
echo -e "${GREEN}Use the password above for the initial setup${NC}"
echo -e "${GREEN}==================================================${NC}"
echo -e "${YELLOW}Don't forget to configure the Google Cloud firewall settings!${NC}"
