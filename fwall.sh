#!/bin/bash
# fwall.sh - A simple relatively hardened 'ufw' based firewall setup script for net connected clients, laptops etc.
echo "Setting up Firewall..."
# Disable and reset the firewall
sudo ufw disable
echo y | sudo ufw reset
# Save the existing log file with a timestamp
timestamp=$(date +"%Y%m%d_%H%M%S")
if [ -f "/var/log/ufw.log" ]; then
  sudo mv /var/log/ufw.log /var/log/ufw.log.bak_$timestamp
  echo 'Backed up old firewall log file:///var/log/ufw.log.bak_'$timestamp
else
  echo 'No existing firewall log file found. Skipping backup.'
fi
# Add a formatted entry as the first line of the new UFW log file
timestamp=$(date +"%b %d %H:%M:%S")
hostname=$(hostname)
echo "$timestamp $hostname kernel: [UFW AUDIT] Firewall setup script started" | sudo tee /var/log/ufw.log > /dev/null
# Enable UFW
sudo ufw enable
# Default policies
sudo ufw default deny incoming
sudo ufw default deny outgoing log-all # log-all blocked requests only, no logs for allowed
# Allow established and related connections
sudo ufw default allow routed
# Allow NTP traffic for security time syncing purposes
sudo ufw allow out to any port 123 proto udp comment 'Allow NTP'
# Limit ICMP traffic: ICMP (Internet Control Message Protocol) is used for diagnostic purposes, but it can also be used for reconnaissance by attackers.
echo 'Allowing only essential ICMP message types'
# Clear existing iptables rules for ICMP
sudo iptables -D OUTPUT -p icmp --icmp-type destination-unreachable -j ACCEPT 2>/dev/null
sudo iptables -D OUTPUT -p icmp --icmp-type time-exceeded -j ACCEPT 2>/dev/null
sudo iptables -D OUTPUT -p icmp -j DROP 2>/dev/null
# Apply ICMP rules directly via iptables
sudo iptables -A OUTPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type time-exceeded -j ACCEPT
sudo iptables -A OUTPUT -p icmp -j DROP
# Allow DNS ((UN?)Trusted DNS Servers)
sudo ufw allow out to 1.1.1.1 port 53 comment 'Cloudflare DNS'
sudo ufw allow out to 8.8.8.8 port 53 comment 'Google DNS'
# Allow DNS (Alternative DNS Servers)
sudo ufw allow out to 9.9.9.9 port 53 comment 'Quad9 DNS'
sudo ufw allow out to 149.112.112.112 port 53 comment 'Quad9 DNS'
sudo ufw allow out to 208.67.222.222 port 53 comment 'Cisco OpenDNS'
sudo ufw allow out to 208.67.220.220 port 53 comment 'Cisco OpenDNS'
sudo ufw allow out to 185.228.168.9 port 53 comment 'Cleanbrowsing'
sudo ufw allow out to 185.228.169.9 port 53 comment 'Cleanbrowsing'
sudo ufw allow out to 64.6.64.6 port 53 comment 'Verisign DNS'
sudo ufw allow out to 64.6.65.6 port 53 comment 'Verisign DNS'
sudo ufw allow out to 94.140.14.14 port 53 comment 'Adguard DNS'
sudo ufw allow out to 94.140.15.15 port 53 comment 'Adguard DNS'
sudo ufw allow out to 8.26.56.26 port 53 comment 'Comodo Secure DNS'
sudo ufw allow out to 8.20.247.20 port 53 comment 'Comodo Secure DNS'
sudo ufw allow out to 199.85.126.10 port 53 comment 'Norton ConnectSafe'
sudo ufw allow out to 199.85.127.10 port 53 comment 'Norton ConnectSafe'
# Allow HTTP and HTTPS
sudo ufw allow out 80 comment 'Allow HTTP'
sudo ufw allow out 443 comment 'Allow HTTPS'
# Enable logging to a dedicated file (default: file:///var/log/ufw.log )
sudo ufw logging medium
# off: Disable logging.
# low: Log only blocked packets.
# medium: Log blocked packets and new connections.
# high: Log blocked packets, new connections, and packet source/destination information.
# full: Log all packets, providing the most detailed information.

# Reload UFW to apply changes
sudo ufw reload
# Show UFW status and rules
sudo ufw status # verbose numbered
echo "Firewall setup!"
