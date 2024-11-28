#!/bin/bash

# Exit on error
set -e

# Configuration
VPN_HOST="***"
VPN_PORT=***

# Resolve the IP address of vpn.stealz.moe
VPN_IP=$(dig +short "$VPN_HOST")

# Check if the IP was resolved successfully
if [[ -z "$VPN_IP" ]]; then
    echo "Error: Could not resolve IP for $VPN_HOST"
    exit 1
fi

echo "Resolved IP for $VPN_HOST: $VPN_IP"

# Apply iptables rules
sudo iptables -t nat -A PREROUTING -i enp1s0 -p udp --dport "$VPN_PORT" -j DNAT --to-destination "${VPN_IP}:${VPN_PORT}"
sudo iptables -A FORWARD -p udp -d "$VPN_IP" --dport "$VPN_PORT" -j ACCEPT
sudo iptables -t nat -A POSTROUTING -p udp -d "$VPN_IP" --dport "$VPN_PORT" -j MASQUERADE

# Allow the port through UFW
sudo ufw allow "$VPN_PORT/udp"

echo "Iptables rules applied successfully!"