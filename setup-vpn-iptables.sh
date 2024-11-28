#!/bin/bash

# Exit on error
set -e

# Resolve the IP address
VPN_HOST=""
VPN_IP=$(dig +short "$VPN_HOST")

# Check if the IP was resolved successfully
if [[ -z "$VPN_IP" ]]; then
    echo "Error: Could not resolve IP for $VPN_HOST"
    exit 1
fi

echo "Resolved IP for $VPN_HOST: $VPN_IP"

# Apply iptables rules
sudo iptables -t nat -A PREROUTING -i enp1s0 -p udp --dport 51820 -j DNAT --to-destination "$VPN_IP:51820"
sudo iptables -A FORWARD -p udp -d "$VPN_IP" --dport 51820 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -p udp -d "$VPN_IP" --dport 51820 -j MASQUERADE

# Allow the port through UFW
sudo ufw allow 51820/udp

echo "Iptables rules applied successfully!"
