#!/bin/bash

# Install netselect if it's not already installed
if ! command -v netselect > /dev/null; then
    echo "netselect is not installed. Installing..."
    sudo apt install netselect -y
fi

# Fetch the list of Ubuntu mirrors
echo "Fetching the list of mirrors..."
wget -qO- http://mirrors.ubuntu.com/mirrors.txt | sed '/^$/d' > mirrors.txt

# Use netselect to find the fastest mirror
echo "Finding the fastest mirror..."
fastest_mirror=$(netselect -s 1 -t 20 $(cat mirrors.txt) | cut -d' ' -f2)

echo "The fastest mirror is: $fastest_mirror"

# Update the sources.list to use the fastest mirror
echo "Updating /etc/apt/sources.list to use the fastest mirror..."
sudo sed -i "s|http://.*.ubuntu.com/ubuntu/|$fastest_mirror|g" /etc/apt/sources.list

# Clean up the mirror list file
rm mirrors.txt

# Update apt sources
echo "Updating apt sources..."
sudo apt update

echo "All done!"
