# _System Dashboard Bash Script_

## Overview

This Bash script provides a comprehensive system dashboard that includes:

- Top 10 CPU and memory-consuming applications
- Number of active processes
- Total, used, and free memory
- Status of essential services
- Disk usage with warnings for partitions over 80% usage
- Breakdown of CPU usage
- Number of concurrent connections
- Packet drops
- Network traffic in and out (in MB)

## Features

### 1. Top 10 CPU and Memory Consuming Applications

**Commands:**

```bash
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 11 | awk '{if(NR>1) print "  PID: " $1 "  Command: " $2 "  CPU: " $3 "%"}'
ps -eo pid,comm,%mem --sort=-%mem | head -n 11 | awk '{if(NR>1) print "  PID: " $1 "  Command: " $2 "  Memory: " $3 "%"}'
```
#### Explanation:

- **'ps -eo pid,comm,%cpu --sort=-%cpu'** : Lists all processes with their PID, command name, and CPU usage, sorted by CPU usage in descending order.
- **'head -n 11'**: Takes the top 11 lines from the output (the first line is the header, so this effectively gives the top 10 processes).
- **'awk '{if(NR>1) print ...}'** : Processes the output to format it, skipping the header line.

A similar command is used for memory usage, sorting by memory consumption and displaying the top 10 processes.

### 2. Number of Active Processes
**Commands:**
```sh
ps aux | wc -l
```
#### Explanation:

- **'ps aux'** : Lists all running processes with detailed information.
- **'wc -l'** : Counts the number of lines in the output, giving the total number of active processes.

### 3. Memory Usage
**Command:**
```sh
free -hm
```
#### Explanation:

- '**free -hm'** : Displays memory usage in a human-readable format with sizes in MB and GB. It shows total, used, free, shared, buffer/cache, and available memory.

### 4. Status of Essential Services
**Commands:**
```sh
systemctl is-active --quiet sshd
systemctl is-active --quiet jenkins
systemctl is-active --quiet ansible
```

#### Explanation:

- **'systemctl is-active --quiet <service>'** : Checks if a specified service (like sshd, jenkins, or ansible) is currently running. The command returns a success (exit code 0) if the service is active, otherwise it returns a failure (non-zero exit code).

### 5. Disk Usage
**Commands:**
```sh
df -h | awk 'NR==1 {print "  " $0} NR>1 {if ($5+0 > 80) print "WARNING (Used more than 80%):"$0; else print "  "$0}'
```

#### Explanation:

- **'df -h'** : Displays disk space usage for all mounted filesystems in a human-readable format (sizes in GB and MB).
- **'awk 'NR==1 {print " " $0} NR>1 {if ($5+0 > 80) print "WARNING (Used more than 80%):"$0; else print " "$0}' '** : Processes the output to add a warning message for filesystems where usage exceeds 80%.

### 6. CPU Usage Breakdown
**Commands:**
```sh
cat /proc/loadavg | awk '{print "Load Average : "  $1,$2,$3}'
top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | sed 's/\,//'
top -bn1 | grep 'Cpu(s)' | awk '{print $4}' | sed 's/\,//'
top -bn1 | grep 'Cpu(s)' | awk '{print $8}' | sed 's/\,//'
```
#### Explanation:

- **'cat /proc/loadavg'** : Shows the system load averages over the last 1, 5, and 15 minutes.
- **'top -bn1 | grep 'Cpu(s)' '**: Extracts CPU usage information from the top command.
- **'awk and sed'** : Process and format the output to display user, system, and idle CPU percentages.

### 7. Number of Concurrent Connections
**Commands:**
```sh
ss -s | grep 'TCP:' | awk '{print $4}' | sed 's/[^0-9]*//g'
```
#### Explanation:

- **'ss -s'**: Displays summary statistics about network sockets.
- **'grep 'TCP:' '**: Filters the output to include only TCP connection statistics.
- **'awk '{print $4}' '**: Extracts the number of TCP connections.
- **' sed 's/[^0-9]*//g' '**: Removes any non-numeric characters, leaving only the count.

### 8. Packet Drops
**Commands:**
```sh
ifstat -i $(ip link show | grep 'state UP' | awk '{print $2}' | sed 's/://') 1 1 | tail -n +3 | awk '{print "In: " $1 " Dropped, Out: " $2 " Dropped"}'
```
#### Explanation:

- **'ifstat -i '** : Displays network interface statistics (replace interface with your active network interface).
- **'tail -n +3'** : Skips the first two lines (headers) and processes the rest.
- **' awk '{print "In: " $1 " Dropped, Out: " $2 " Dropped"}' '**: Formats the - output to display packet drops.

### 9. Network Traffic in MB

**Commands:**
```sh
ifstat -i $(ip link show | grep 'state UP' | awk '{print $2}' | sed 's/://') 1 1 | tail -n +3 | awk '{print "In: " $1 " KB, Out: " $2 " KB"}' | awk '{print "In: " $1/1024 " MB, Out: " $2/1024 " MB"}'
```
#### Explanation:

- **'ifstat -i '**: Displays network traffic statistics.
- **'awk '{print "In: " $1 " KB, Out: " $2 " KB"}' '** : Outputs traffic in kilobytes.
- **'awk '{print "In: " $1/1024 " MB, Out: " $2/1024 " MB"}' '** : Converts kilobytes to megabytes.



## Installation

1. **Clone the Repository**

```bash
 git clone https://github.com/your-username/your-repository.git
```

2. **Navigate to the Script Directory**
```sh
cd your-repository
```
3. **Make the Script Executable**
```sh
chmod +x NameOfYourScript.sh
```
# Configuration
1. Set Up Required Tools

#### Ensure that the following tools are installed on your system:

- ps
- awk
- free
- systemctl
- df
- top
- ss
- ifstat (Install using sudo apt-get install ifstat on Debian-based systems)

2. Update Service Names
    
    If you have different essential services, update the 'show_services_status' function in the script to include or exclude services as needed.

3. Network Interface Configuration
    
    The script uses the network interface that is in the 'UP' state. You may need to adjust this if you have multiple interfaces or specific needs.

# Usage

### You can use the script in two ways:

1. Run the Dashboard in a Loop

    This will clear the screen every 30 seconds and update the dashboard with fresh data.
    ```sh
    sudo ./system_dashboard.sh
    ```
2. Run Specific Functions

    You can run individual sections of the dashboard by passing one of the following options:
    ```sh
    ./system_dashboard.sh --top
    ./system_dashboard.sh --processes
    ./system_dashboard.sh --services
    ./system_dashboard.sh --disk
    ./system_dashboard.sh --cpu
    ./system_dashboard.sh --memory
    ./system_dashboard.sh --connections
    ./system_dashboard.sh --packet-drops
    ./system_dashboard.sh --traffic
    ```
    ### Example :
    ```sh
    ./system_dashboard.sh --top
    ```
    This will display only the _Top CPU and Memory Consuming Applications_

    ### Example Output :
    **Top 10 CPU and Memory consuming Applications:**
    ```sh
    Top 10 CPU and Memory Consuming Applications:
    CPU Usage:
    PID: 1839  Command: cinnamon  CPU: 6.7%
    PID: 1138  Command: Xorg  CPU: 3.1%
    PID: 837  Command: java  CPU: 2.7%
    PID: 2122  Command: gnome-terminal-  CPU: 0.8%
    PID: 1563  Command: VBoxClient  CPU: 0.5%
    PID: 630  Command: touchegg  CPU: 0.2%
    PID: 2224  Command: mintreport-tray  CPU: 0.2%
    PID: 1  Command: systemd  CPU: 0.1%
    PID: 9  Command: kworker/u6:0-ev  CPU: 0.1%
    PID: 23  Command: kworker/1:0-eve  CPU: 0.1%
    Memory Usage:
    PID: 837  Command: java  Memory: 10.7%
    PID: 1839  Command: cinnamon  Memory: 7.7%
    PID: 1138  Command: Xorg  Memory: 4.0%
    PID: 2162  Command: mintUpdate  Memory: 3.0%
    PID: 1884  Command: evolution-alarm  Memory: 2.0%
    PID: 1888  Command: nemo-desktop  Memory: 2.0%
    PID: 1885  Command: blueman-applet  Memory: 1.9%
    PID: 2224  Command: mintreport-tray  Memory: 1.6%
    PID: 1898  Command: nm-applet  Memory: 1.5%
    PID: 2122  Command: gnome-terminal-  Memory: 1.4%
    ```
