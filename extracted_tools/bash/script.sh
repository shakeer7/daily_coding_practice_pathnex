#!/bin/bash
# ==========================================
# Consolidated Pathnex Bash Script
# ==========================================

# ==========================================
# 1. System Information & Checks
# ==========================================
echo "--- System Info ---"
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "IP: $(hostname -I)"
echo "Uptime: $(uptime)"
echo "Current user: $(whoami)"
echo "Current user group: $(groups)"

echo "--- Performance Metrics ---"
# Show disk usage
df -h
USAGE=$(df -h / | tail -1 | awk '{print $5}')
echo "Disk Usage: $USAGE"

# Show CPU Load
LOAD=$(uptime | awk '{print $10}')
echo "Current CPU Load: $LOAD"

# Show Top 6 Memory Consuming Processes
echo "Top Memory Consuming Processes:"
ps aux --sort=-%mem | head -n 6

# Find and Kill Highest CPU Process (Warning: Use carefully)
# PID=$(ps aux --sort=-%cpu | awk 'NR==2{print $2}')
# echo "Killing process: $PID"
# kill -9 $PID

# Check Internet Connection
ping -c 2 google.com &> /dev/null
if [ $? -eq 0 ]; then
    echo "Internet is available"
else
    echo "No internet connection"
fi


# ==========================================
# 2. Service Management
# ==========================================
echo "--- Service Management ---"
# Install and start httpd
# yum install -y httpd
# systemctl start httpd

# Check status of multiple services
services=("nginx" "docker" "httpd")
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        echo "$service is running"
    else
        echo "$service is not running"
    fi
done


# ==========================================
# 3. File & Log Management
# ==========================================
echo "--- File & Log Management ---"
# Count files in log directory
DIR="/var/log"
COUNT=$(ls $DIR | wc -l)
echo "Total files in $DIR: $COUNT"

# Archive log files
# tar -czf /var/log/archived_logs.tar.gz /var/log/*.log
# tar -czf /backup/pathnex-logs-$(date +%F).tar.gz /var/log/
# echo "Logs archived."

# Read lines from a file
# FILE="/etc/passwd"
# while read line; do
#     echo "Line: $line"
# done < $FILE


# ==========================================
# 4. Docker Commands
# ==========================================
echo "--- Docker Operations ---"
# Build Docker image
# docker build -t pathnex-nginx .

# Run Docker containers
# docker run -d -p 80:80 pathnex-nginx
# docker run -d --memory="512m" --cpus="1.0" nginx

# Docker volumes and backups
# docker volume create pathnex-volume
# docker run --rm -v pathnex-volume:/data -v $(pwd):/backup ubuntu tar czf /backup/pathnex-backup.tar.gz /data


# ==========================================
# 5. Interactive Scripting Example
# ==========================================
# greet() {
#     echo "Welcome to Pathnex DevOps Training"
# }
# greet
#
# echo "Interactive Menu:"
# echo "1) Show date"
# echo "2) Show uptime"
# echo "3) Show users"
# read -p "Choose option: " opt
# case $opt in
#     1) date ;;
#     2) uptime ;;
#     3) who ;;
#     *) echo "Invalid choice" ;;
# esac
