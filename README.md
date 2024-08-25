# Technical-Task 2
# Security Audit Script
## Overview
*This script performs a comprehensive security audit on a Linux system. It checks various aspects such as user accounts, file permissions, network configurations, services, and more. The output is saved in a security_report.txt file.*

# Prerequisites 

- __A Linux-based system__
- __Basic command-line tools (awk, find, ls, grep, ss, nmap, etc.)__
- __Root or sudo access may be required for some checks__

# Installation

1. Clone or Download the Script

Download the script to your local machine or server. For example, you might use 'curl' or 'wget' if hosted online, or clone from a repository:
```bash
wget https://example.com/path/to/security_audit_script.sh -O security_audit_script.sh
```
or
```bash
 git clone https://example.com/path/to/repository.git
```
2. Make the Script Executable

After downloading, make the script executable:
```bash
chmod +x security_audit_script.sh
```
3. Create and Configure the Configuration File

Create a configuration file named config.cfg in the same directory as the script. Include any required configuration options, such as:

```bash
ALERT_EMAIL="your.email@example.com"
AUTHORIZED_PORTS=("22" "80" "443")
CRITICAL_SERVICES=("sshd" "apache2" "mysql")
```

# Usage
  
1. Run the Script

Execute the script to start the security audit:

```bash
sudo ./nameOfYourScript.sh
```
The script will generate a "security_report.txt" file in the current directory.

2. Review the Report

Open security_report.txt to review the results of the audit:
```sh
cat security_report.txt
```

# Configuration

- ALERT_EMAIL: Set this variable in config.cfg to receive email alerts (Note: Email alert functionality is currently commented out in the script).
- AUTHORIZED_PORTS: List of ports that are considered authorized. The script checks if any open ports are unauthorized.
- CRITICAL_SERVICES: List of services considered critical. The script checks if these services are running.

# _1. User and Group Management_

### List Users and Groups

- Command:
```sh
 cut -d: -f1 /etc/passwd and cut -d: -f1 /etc/group
```
- Description: Lists all user accounts and groups by extracting usernames and group names from the '/etc/passwd' and '/etc/group files'.

### Check for UID '0' Users

- Command:
```sh
 awk -F: '($3 == 0) {print $1}' /etc/passwd
 ```
- Description: Identifies any users with UID 0, which indicates root or superuser privileges.

### Find Users with Empty Passwords or Weak Passwords

- Command:
```sh
awk -F: '($2 == "" || $2 == "x") {print $1}' /etc/shadow
```
- Description: Detects users with empty passwords or weak passwords by examining the '/etc/shadow' file.


# _2. File and Directory Security_

### Scan for World-Writable Files and Directories

- Command: 
```sh
find / -xdev \( -type f -o -type d \) -perm -0002 -exec ls -ld {} \; 2>/dev/null
```
- Description: Lists files and directories that are world-writable (permissions -0002), which can be a security risk.

### Check '.ssh' Directory Permissions

- Command: 
```sh
find /home -name .ssh -type d -exec ls -ld {} \; 2>/dev/null
```
- Description: Verifies the permissions of '.ssh' directories under /home to ensure they are properly secured.

# _3. Network Configuration_

### Identify Public vs. Private IPs

- Command:
```sh
 hostname -I
 ```
- Description: Retrieves the system’s IP addresses and classifies them as public or private based on predefined IP ranges.

### Check IP Forwarding

- Command: 
```sh
sysctl net.ipv4.ip_forward and sysctl net.ipv6.conf.all.forwarding
```
- Description: Checks the IP forwarding settings for both IPv4 and IPv6 to ensure proper network configuration.

# _4. Service Management_

### List Running Services

- Command: 
```sh
systemctl list-units --type=service --state=running
```
- Description: Lists all currently running services using systemctl.

### Check for Unauthorized Services

- Command: 
```sh
ss -tuln | awk '{print $5}' | cut -d: -f2 | sort -u
```
- Description: Identifies any services running on unauthorized ports by comparing with a list of approved ports.

### Verify Critical Services
- Command: 
```sh
systemctl is-active --quiet "$SERVICE"
```
- Description: Checks if critical services, specified in the configuration file, are currently active.

# _5. Security and Access Controls_

### Report SUID/SGID Files

- Command:
```sh
 find / -type f \( -perm -04000 -o -perm -02000 \) -exec ls -l {} \; 2>/dev/null
 ```
- Description: Finds files with SUID or SGID bits set, which can pose security risks.

### Check Firewall Status

- Command: 
```sh
ufw status or iptables -L -n
```
- Description: Reports the status of the firewall using either ufw or iptables, depending on which is available.

### Scan for Available Security Updates


- Command: 
```sh
apt-get update && apt-get -s upgrade | grep "^Inst" | awk '{print $1,$2}' for apt-get, yum check-update for yum, or dnf check-update for dnf
```
- Description: Lists available security updates for installed packages, based on the package manager in use.

# _6. Log Analysis_

### Check Logs for Suspicious Activity

- Command:
 ```sh
 grep "sshd.*Failed password" /var/log/auth.log or grep "sshd.*Accepted password" /var/log/auth.log
 ```
- Description: Searches authentication logs for failed or accepted SSH login attempts, indicating possible unauthorized access.


# _7. Port and Service Security_

### Report Open Ports and Associated Services
- Command: 
```sh
nmap localhost | sed -n '4,7p'
```
- Description: Lists open ports and their associated services on the localhost using nmap.


### Check for Unauthorized Ports

- Command: 
```
ss -tuln | awk '{print $5}' | cut -d: -f2 | sort -u
```
- Description: Compares open ports against a list of authorized ports to identify any unauthorized ones.


# Notes

- Ensure you have the necessary permissions to perform the checks, especially if running as a non-root user.
- Some checks, such as scanning all files, may take considerable time.
- Adjust the script as needed based on specific requirements or system configurations.

# Troubleshooting

- Script Not Running: Ensure the script has executable permissions _'(chmod +x)'_.
- Missing Commands: Install missing packages or commands as required by your system.
- Permission Denied Errors: Run the script with _'sudo'_ if required for certain checks.
