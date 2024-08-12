#!/bin/bash
# system_monitor.sh - Advanced system monitoring script with user-friendly output

# Define threshold values (adjust as needed)
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=90
LOG_FILE="$HOME/system_monitor.log"

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print a header
print_header() {
    echo -e "${CYAN}=============================="
    echo -e "$1"
    echo -e "==============================${NC}"
}

# Function to print a status message
print_status() {
    if (( $(echo "$2 > $3" | bc -l) )); then
        echo -e "${RED}WARNING: $1 is above threshold! ($2)${NC}"
    else
        echo -e "${GREEN}$1 is within normal range. ($2)${NC}"
    fi
}

# Capture system metrics
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')
MEM_USAGE=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }')
DISK_USAGE=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//g')
UPTIME=$(uptime -p)
TOP_PROCESSES=$(ps aux --sort=-%mem | awk 'NR<=10{print $0}')

# Capture network activity
NETWORK_INTERFACE=$(ip route | grep '^default' | awk '{print $5}')
NETWORK_RX=$(cat /sys/class/net/$NETWORK_INTERFACE/statistics/rx_bytes)
NETWORK_TX=$(cat /sys/class/net/$NETWORK_INTERFACE/statistics/tx_bytes)
NETWORK_ACTIVITY="Received: $(numfmt --to=iec $NETWORK_RX), Transmitted: $(numfmt --to=iec $NETWORK_TX)"

# Display system monitoring report
{
    print_header "System Monitoring Report: $(date)"
    echo -e "Uptime: ${CYAN}$UPTIME${NC}"
    print_status "CPU Usage" "$CPU_USAGE" "$CPU_THRESHOLD"
    print_status "Memory Usage" "$MEM_USAGE%" "$MEM_THRESHOLD"
    print_status "Disk Usage" "$DISK_USAGE%" "$DISK_THRESHOLD"
    echo -e "${CYAN}Network Activity ($NETWORK_INTERFACE):${NC} $NETWORK_ACTIVITY"
    echo -e "\n${CYAN}Top 10 Memory-Consuming Processes:${NC}\n$TOP_PROCESSES"
    echo -e "${CYAN}==============================${NC}\n"
} | tee -a "$LOG_FILE"

# Optionally, send an alert if any threshold is exceeded (e.g., via email or another method)
# Example: Send an email alert (you'll need to configure mailx or another mail client)
# if [ $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) -eq 1 ] || \
#    [ $(echo "$MEM_USAGE > $MEM_THRESHOLD" | bc -l) -eq 1 ] || \
#    [ $(echo "$DISK_USAGE > $DISK_THRESHOLD" | bc -l) -eq 1 ]; then
#     echo "System resource usage alert!" | mailx -s "System Monitor Alert" user@example.com
# fi

