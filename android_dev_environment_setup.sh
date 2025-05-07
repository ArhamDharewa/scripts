#!/bin/bash
#
# Android Development Environment Setup Script for Google Cloud VM
# This script sets up a complete Android build environment with NoMachine remote desktop
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

echo -e "${GREEN}Starting Android Development Environment Setup...${NC}"

# Update system packages
echo -e "${YELLOW}Updating system packages...${NC}"
sudo apt-get update
sudo apt-get upgrade -y

# Download and run akhilnarang's script for Android build environment
echo -e "${YELLOW}Downloading Android build environment script...${NC}"
curl -O https://raw.githubusercontent.com/akhilnarang/scripts/master/setup/android_build_env.sh
bash android_build_env.sh

# Install desktop environment
echo -e "${YELLOW}Installing Ubuntu Desktop environment...${NC}"
sudo apt-get install -y ubuntu-desktop

# Create new user for building
echo -e "${YELLOW}Creating new user 'arham' for building Android...${NC}"
sudo adduser --gecos "" arham << EOF
123
123
EOF

# Add user to necessary groups
echo -e "${YELLOW}Adding user to groups...${NC}"
sudo usermod -aG sudo,adm arham

# Download and install NoMachine for remote desktop
echo -e "${YELLOW}Installing NoMachine remote desktop...${NC}"
wget https://download.nomachine.com/download/8.16/Linux/nomachine_8.16.1_1_amd64.deb
sudo dpkg -i nomachine_8.16.1_1_amd64.deb


echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}Android Development Environment Setup Complete!${NC}"
echo -e "${GREEN}==================================================${NC}"
echo -e "${YELLOW}NoMachine is installed and can be accessed at: ${EXTERNAL_IP}${NC}"
echo -e "${YELLOW}Username: arham${NC}"
echo -e "${YELLOW}Password: 123 (Please change this immediately!)${NC}"
echo -e "${GREEN}==================================================${NC}"
echo -e "${YELLOW}Don't forget to configure the Google Cloud firewall settings!${NC}"
echo -e "${YELLOW}The system will reboot in 10 seconds...${NC}"

# Wait 10 seconds and reboot
sleep 10
sudo reboot
