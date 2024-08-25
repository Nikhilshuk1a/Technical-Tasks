#!/bin/bash

# Configuration file
CONFIG_FILE="config.cfg"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "Configuration file $CONFIG_FILE not found."
  exit 1
fi

# Function to send email alerts
#send_alert() {
#  local subject="$1"
#  local message="$2"
#  echo "$message" | mail -s "$subject" "$ALERT_EMAIL"
#}

# Utility function to log messages
log() {
    echo "$(date +'%d-%m-%Y %H:%M:%S'):  $1"
}


# Function to list all users and groups

list_users_groups() {
    log "------------------------------------------------------- Listing all Users -----------------------------------------------------------"
    cut -d: -f1 /etc/passwd

    log "----------------------------------------------------------Listing all groups---------------------------------------------"
    cut -d: -f1 /etc/group
}


# Function to check for users with UID 0
check_uid_0() {
  log "----------------------------------------------------- Checking for users with UID 0 -----------------------------------------------------"
  awk -F: '($3 == 0) {print $1}' /etc/passwd
}

# Function to identify users without passwords
check_empty_passwords() {
  log "------------------------------------------------- Checking for users with empty passwords -----------------------------------------------"
  awk -F: '($2 == "") {print $1}' /etc/shadow
}

# Function to scan for world-writable files and directories
scan_world_writable() {
  log "------------------------------------------ Scanning for world-writable files and directories ---------------------------------------------"
  find / -xdev \( -type f -o -type d \) -perm -0002 -exec ls -ld {} \; 2>/dev/null | awk  '{print $3,$4,$5,$9}'
}

# Function to check .ssh directory permissions
check_ssh_permissions() {
  log "---------------------------------------------------- Checking .ssh directory permissions --------------------------------------------------------"
  find /home -name .ssh -type d -exec ls -ld {} \; 2>/dev/null
}

# Function to identify public vs private IPs

identify_ips() {
    log "--------------------------------------------------- Identifying public and private IPs ----------------------------------------------------------"

    # Get all IP addresses
    ips=$(hostname -I)
    for ip in $ips; do
        if [[ $ip =~ ^10\. || $ip =~ ^172\.1[6-9]\. || $ip =~ ^172\.2[0-9]\. || $ip =~ ^172\.3[0-1]\. || $ip =~ ^192\.168\. || $ip =~ ^127\. ]]; then
            echo "$ip is a private IP"
        else
            echo "$ip is a public IP"
        fi
    done
}

# Function to report SUID/SGID files
check_suid_sgid() {
  log "--------------------------------------------------------------- Checking for SUID/SGID files ------------------------------------------------------"
  find / -type f \( -perm -04000 -o -perm -02000 \) -exec ls -l {} \; 2>/dev/null
}

# Function to list running services and check for unauthorized services
check_services() {
  log "------------------------------------------------ Listing all running services -------------------------------------------------------------"
  systemctl list-units --type=service --state=running
}

# Function to check firewall status
check_firewall() {
  log "--------------------------------------------------- Checking firewall status -------------------------------------------------------"
  if command -v ufw >/dev/null; then
    ufw status
  elif command -v iptables >/dev/null; then
    iptables -L -n
  else
    echo "No firewall found."
  fi
}

# Function to check for IP forwarding and insecure network configurations
check_ip_forwarding() {
  log "------------------------------------------------------ Checking IP forwarding ----------------------------------------------"
  sysctl net.ipv4.ip_forward
  sysctl net.ipv6.conf.all.forwarding
}

# Function to check for available security updates
check_updates() {
  log "------------------------------------------------------- Checking for available security updates -----------------------------------------------------------"
  if command -v apt-get >/dev/null; then
    apt-get update && apt-get -s upgrade | grep "^Inst" | awk '{print $1,$2}'
  elif command -v yum >/dev/null; then
    yum check-update
  elif command -v dnf >/dev/null; then
    dnf check-update
  else
    echo "No known package manager found."
  fi
}

# Function to check logs for suspicious activity
check_logs() {
  log "--------------------------------------------- Checking logs for suspicious activity -------------------------------------------------------------"
 if grep "sshd.*Failed password" /var/log/auth.log || grep "sshd.*Accepted password" /var/log/auth.log; then
         echo "$0"
 else
         echo "No Suspicious Activity Found in the logs"
 fi
}

# Function to report any open Ports and their Associated Services
open_ports_svc() {
	log "--------------------------------------------- Checking for any open ports and their services --------------------------------------"
	nmap localhost | sed -n '4,7p'
}

unauthorized_svc() {
log "------------------------------------------------- Checking for unauthorized services on open ports ---------------------------------------------------- "
for PORT in $(ss -tuln | awk '{print $5}' | cut -d: -f2 | sort -u); do
    if [[ ! " ${AUTHORIZED_PORTS[@]} " =~ " ${PORT} " ]]; then
        echo "Unauthorized port open: $PORT"
    fi
done
}
# Function to check the critical services
check_critical_svc() {
log "---------------------------------------------------------- Checking for critical services -----------------------------------------------------------"
for SERVICE in "${CRITICAL_SERVICES[@]}"; do
    if systemctl is-active --quiet "$SERVICE"; then
        echo "Critical service $SERVICE is running"
    else
        echo "Critical service $SERVICE is not running"
    fi
done
}

# Function to generate a summary report
generate_report() {
  echo -e "--------------------------------------- Generating security report ~~~~~~~~~~~~~~~ \n ------------------------------------- Please Wait for few seconds ~~~~~~~~~~~~~~~~~"
  {
    echo "Security Audit Report"
    echo "===================================================================================== "
    list_users_groups
    check_uid_0
    check_empty_passwords
    scan_world_writable
    check_ssh_permissions
    identify_ips
    check_suid_sgid
    check_services
    check_firewall
    check_ip_forwarding
    check_updates
    check_logs
    open_ports_svc
    unauthorized_svc
    check_critical_svc
  } > security_report.txt
  echo "Report generated at $(pwd)/security_report.txt"
#  send_alert "Security Audit Report" "The security audit report has been generated. Please review the file security_report.txt."
}

# Main execution
generate_report
