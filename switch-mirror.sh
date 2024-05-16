#!/bin/bash

# Check if netselect is installed, and install if necessary
if ! command -v netselect > /dev/null; then
    echo "netselect is not installed. Installing..."
    sudo apt install netselect -y
fi

# Function to add iptables rules
add_iptables_rules() {
    echo "Adding iptables rules to allow ICMP (ping)..."
    sudo iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
    sudo iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
}

# Function to remove iptables rules
remove_iptables_rules() {
    echo "Removing iptables rules for ICMP (ping)..."
    sudo iptables -D OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
    sudo iptables -D INPUT -p icmp --icmp-type echo-reply -j ACCEPT
}

# Add iptables rules to allow outbound pings
add_iptables_rules

# Fetch the list of Ubuntu mirrors
echo "Fetching the list of mirrors..."
wget -qO- https://launchpad.net/ubuntu/+archivemirrors | grep -oP 'https://[^/]+\.(?:at|be|bg|cy|cz|de|dk|ee|es|fi|fr|gr|hr|hu|ie|it|lt|lu|lv|mt|nl|pl|pt|ro|se|si|sk|eu)/ubuntu' > mirrors.txt

if [[ ! -s mirrors.txt ]]; then
    echo "Failed to fetch mirrors or no mirrors found."
    remove_iptables_rules
    exit 1
fi

echo "Finding the fastest mirror..."
fastest_mirror=""
fastest_time=9999999

while read -r mirror; do
    echo "Testing mirror: $mirror"
    # Use curl to test the mirror
    response=$(curl -o /dev/null -s -w "%{time_total}" $mirror)
    if [[ $? -ne 0 ]]; then
        echo "Skipping $mirror (unreachable)"
    else
        echo "Time taken for $mirror: $response"
        if (( $(echo "$response < $fastest_time" | bc -l) )); then
            fastest_mirror=$mirror
            fastest_time=$response
        fi
    fi
done < mirrors.txt

if [[ -z "$fastest_mirror" ]]; then
    echo "No reachable mirror found. Using a default mirror..."
    fastest_mirror="http://archive.ubuntu.com/ubuntu/"
fi

echo "The fastest mirror is: $fastest_mirror"

# Clean up the mirror list file
rm mirrors.txt

# Update apt sources
echo "Updating apt sources..."
sudo sed -i "s|http://archive.ubuntu.com/ubuntu/|$fastest_mirror|g" /etc/apt/sources.list
sudo apt update

# Remove iptables rules
remove_iptables_rules

echo "All done!"
