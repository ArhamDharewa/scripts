# Google Cloud Android Build & Jenkins Setup

This repository contains scripts for setting up Android build environments and Jenkins CI/CD on Google Cloud Platform VMs. These scripts automate the installation and configuration process to get you up and running quickly.

## Scripts Overview

### 1. Android Development Environment Setup

The `android_dev_environment_setup.sh` script sets up a complete Android build environment on a Linux VM with a remote desktop interface.

**Features:**
- Installs Android build dependencies using akhilnarang's scripts
- Sets up Ubuntu Desktop environment
- Creates a user account for building Android
- Configures SSH for password authentication
- Installs NoMachine for remote desktop access

### 2. Jenkins Installation Script

The `jenkins_install.sh` script installs and configures Jenkins CI/CD server on a Linux VM.

**Features:**
- Installs OpenJDK 11 (required for Jenkins)
- Adds the Jenkins repository
- Installs and starts the Jenkins service
- Configures the system firewall (UFW)
- Retrieves the initial admin password
- Displays the URL to access your Jenkins instance

## Installation Instructions

### Prerequisites

- A Google Cloud Platform account
- A Linux VM instance (Ubuntu is recommended)
- SSH access to the VM

### Setting Up Android Development Environment

1. Connect to your VM via SSH:
   ```bash
   ssh username@your-vm-ip
   ```

2. Download the script:
   ```bash
   wget -O android_dev_environment_setup.sh https://raw.githubusercontent.com/ArhamDharewa/scripts/main/android_dev_environment_setup.sh
   ```

3. Make the script executable:
   ```bash
   chmod +x android_dev_environment_setup.sh
   ```

4. Run the script:
   ```bash
   ./android_dev_environment_setup.sh
   ```

5. After the VM reboots, you can connect using NoMachine client with:
   - Server: Your VM's IP address
   - Username: arham
   - Password: 123 (change this immediately!)

### Setting Up Jenkins

1. Connect to your VM via SSH:
   ```bash
   ssh username@your-vm-ip
   ```

2. Download the script:
   ```bash
   wget -O jenkins_install.sh https://raw.githubusercontent.com/ArhamDharewa/scripts/main/jenkins_install.sh
   ```

3. Make the script executable:
   ```bash
   chmod +x jenkins_install.sh
   ```

4. Run the script:
   ```bash
   ./jenkins_install.sh
   ```

5. After installation completes, access Jenkins at:
   ```
   http://your-vm-ip:8080
   ```

6. Use the initial admin password displayed at the end of the installation to complete the setup.

## Google Cloud Firewall Settings

### For Android Development Environment with NoMachine

Create a firewall rule for NoMachine:
- Name: `nomachine-access`
- Network: Select your VPC network
- Priority: `1000`
- Direction of traffic: `Ingress`
- Action on match: `Allow`
- Targets: Specified target tags (add the tag to your VM)
- Target tags: `nomachine`
- Source filter: IP ranges
- Source IP ranges: Your IP address or range (for security)
- Protocols and ports: `tcp:4000-4100`

### For Jenkins

Create a firewall rule for Jenkins:
- Name: `jenkins-port-8080`
- Network: Select your VPC network
- Priority: `1000`
- Direction of traffic: `Ingress`
- Action on match: `Allow`
- Targets: Specified target tags (add the tag to your VM)
- Target tags: `jenkins`
- Source filter: IP ranges
- Source IP ranges: Your IP address or range (for security)
- Protocols and ports: `tcp:8080`

## Using Jenkins for Android ROM Building

After both environments are set up, you can use Jenkins to automate your Android ROM builds:

1. Create a new Jenkins job
2. Configure the job to use the build.txt script from the repository
3. Set up the necessary environment variables (LUNCH, TG_NAME, etc.)
4. Configure build triggers as needed

## Security Considerations

- Change default passwords immediately
- Use specific IP addresses in firewall rules rather than allowing all traffic
- Consider using SSH keys instead of password authentication
- Keep your system and Jenkins updated regularly
- Use HTTPS for Jenkins with a proper SSL certificate

## Troubleshooting

- If NoMachine connection fails, check that ports 4000-4100 are open in the firewall
- If Jenkins isn't accessible, verify port 8080 is open in the firewall
- For build failures, check the logs in Jenkins console output
- If SSH password authentication doesn't work, verify sshd_config changes were applied

## Contributing

Feel free to submit issues or pull requests to improve these scripts.

## License

[MIT License](LICENSE)
