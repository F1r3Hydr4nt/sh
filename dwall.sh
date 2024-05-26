#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
  # No argument provided, prompt for one
  read -p "Enter the duration in seconds to disable the firewall: " duration
else
  # Use the provided argument as the duration
  duration=$1
fi

# Ensure the duration is a valid number
if ! [[ "$duration" =~ ^[0-9]+$ ]]; then
  echo "Error: Duration must be a numeric value."
  exit 1
fi

echo "Disabling Firewall for $duration seconds..."

# Disable UFW
sudo ufw disable

# Wait for the specified duration
sleep "$duration"

echo "Re-enabling Firewall..."

# Run the fwall.sh script
bash "$(dirname "$0")/fwall.sh"
