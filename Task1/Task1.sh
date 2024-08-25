#!/bin/bash

# Function to display the top 10 most CPU and memory consuming applications
show_top_apps() {
    echo "Top 10 CPU and Memory Consuming Applications:"
    echo "CPU Usage:"
    ps -eo pid,comm,%cpu --sort=-%cpu | head -n 11 | awk '{if(NR>1) print "  PID: " $1 "  Command: " $2 "  CPU: " $3 "%"}'
    
    echo "Memory Usage:"
    ps -eo pid,comm,%mem --sort=-%mem | head -n 11 | awk '{if(NR>1) print "  PID: " $1 "  Command: " $2 "  Memory: " $3 "%"}'
}

# Function to display the number of active processes
show_active_processes() {
    echo "Number of Active Processes:"
    ps aux | wc -l
}

# Function to display total, used and free memory
show_memory() {
    echo "Memory Usage:"
    free -hm
}

# Function to display the status of essential services
show_services_status() {
    echo "Status of Essential Services:"
    for service in sshd; do
        systemctl is-active --quiet $service
        if [ $? -eq 0 ]; then
            echo "  $service: Running"
        else
            echo "  $service: Not Running"
        fi
    done
    for service in jenkins; do
        systemctl is-active --quiet $service
        if [ $? -eq 0 ]; then
            echo "  $service: Running"
        else
            echo "  $service: Not Running"
        fi
    done
    for service in ansible; do
        systemctl is-active --quiet $service
        if [ $? -eq 0 ]; then
            echo "  $service: Running"
        else
            echo "  $service: Not Running"
        fi
    done


}

# Function to display disk usage and highlight partitions with more than 80% usage
show_disk_usage() {
    echo "Disk Usage:"
    df -h | awk 'NR==1 {print "  " $0} NR>1 {if ($5+0 > 80) print "WARNING (Used more than 80%):"$0; else print "  "$0}'
}

# Function to display a breakdown of CPU usage
show_cpu_breakdown() {
    cat /proc/loadavg | awk '{print "Load Average : "  $1,$2,$3}'    
    echo "CPU Usage Breakdown:"
    echo "  User: $(top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | sed 's/\,//')%"
    echo "  System: $(top -bn1 | grep 'Cpu(s)' | awk '{print $4}' | sed 's/\,//')%"
    echo "  Idle: $(top -bn1 | grep 'Cpu(s)' | awk '{print $8}' | sed 's/\,//')%"
}

# Function to display the number of concurrent connections
show_connections() {
    echo "Number of concurrent connections:"
    # Using `ss` to show the number of connections. Adjust as needed.
    ss -s | grep 'TCP:' | awk '{print $4}' | sed 's/[^0-9]*//g'
}

# Function to display packet drops
show_packet_drops() {
    echo "Packet drops:"
    # Using `ifstat` to show packet drops. Adjust as needed.
    ifstat -i $(ip link show | grep 'state UP' | awk '{print $2}' | sed 's/://') 1 1 | tail -n +3 | awk '{print "In: " $1 " Dropped, Out: " $2 " Dropped"}'
}

# Function to display the number of MB in and out
show_traffic() {
    echo "Network traffic in MB:"
    # Using `ifstat` to show network traffic
    ifstat -i $(ip link show | grep 'state UP' | awk '{print $2}' | sed 's/://') 1 1 | tail -n +3 | awk '{print "In: " $1 " KB, Out: " $2 " KB"}' | awk '{print "In: " $1/1024 " MB, Out: " $2/1024 " MB"}'
}


# Function to clear the screen and display the dashboard
refresh_dashboard() {
    clear
    echo "System Dashboard - $(date)"
    echo "----------------------------------------------------------------------------------------------------------------------"
    show_top_apps
    show_active_processes
    show_memory
    show_services_status
    show_disk_usage
    show_cpu_breakdown
    show_connections
    show_packet_drops
    show_traffic
    show_connections
    show_traffic
    show_packet_drops

}

# Main logic to handle command line switches and refresh interval
if [[ $# -eq 0 ]]; then
    # No arguments; run the dashboard in a loop
    while true; do
        refresh_dashboard
        sleep 30
    done
else
    # Command line arguments
    case "$1" in
        --top)
            show_top_apps
            ;;
        --processes)
            show_active_processes
            ;;
        --services)
            show_services_status
            ;;
        --disk)
            show_disk_usage
            ;;
        --cpu)
            show_cpu_breakdown
            ;;
	--memory)
	    show_memory
	    ;;
        --connections)
	    show_connections
	    ;;
        --packet-drops)
	    show_packet_drops
	    ;;
	--traffic)
	    show_traffic
	    ;;
        *)
            echo "Usage: $0 [--top | --processes | --services | --disk | --cpu | --memory | --connections | --packet-drops | --traffic]"
            ;;
    esac
fi
