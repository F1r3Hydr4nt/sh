#!/bin/bash
# This script clears system caches and displays the amount of RAM reclaimed in appropriate units (bytes, kB, MB, GB).

# Function to convert memory from kB to appropriate units
pretty_print_memory() {
    local memory_kb=$1
    local memory_b=$((memory_kb * 1024))
    if [[ $memory_b -lt 1024 ]]; then
        echo "${memory_b} bytes"
    elif [[ $memory_b -lt 1048576 ]]; then
        local memory_kb=$((memory_b / 1024))
        echo "${memory_kb} kB"
    elif [[ $memory_b -lt 1073741824 ]]; then
        local memory_mb=$((memory_b / 1048576))
        echo "${memory_mb} MB"
    else
        local memory_gb=$((memory_b / 1073741824))
        echo "${memory_gb} GB"
    fi
}

# Capture the amount of free memory before clearing caches
FREE_BEFORE=$(awk '/MemFree/ {print $2}' /proc/meminfo)

# Clearing the caches:
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'

# Capture the amount of free memory after clearing caches
FREE_AFTER=$(awk '/MemFree/ {print $2}' /proc/meminfo)

# Calculate reclaimed memory in kB
RECLAIMED=$(($FREE_AFTER - $FREE_BEFORE))

# Pretty print the reclaimed memory
echo "Reclaimed $(pretty_print_memory $RECLAIMED) of RAM"

