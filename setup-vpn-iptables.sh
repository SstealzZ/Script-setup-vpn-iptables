#!/bin/bash

# Vérification des privilèges root
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être exécuté en tant que root"
   exit 1
fi

# Exit on error
set -e

# Configuration
VPN_HOST="xxx.xxx.xxx.xxx"
ENTRY_PORT="xxxxx"
EXIT_PORT="xxxxx"

# Resolve the IP address
VPN_IP=$(dig +short "$VPN_HOST")

# Check if the IP was resolved successfully
if [[ -z "$VPN_IP" ]]; then
    echo "Error: Could not resolve IP for $VPN_HOST"
    exit 1
fi

echo "Resolved IP for $VPN_HOST: $VPN_IP"

# Nettoyer les règles existantes potentielles
iptables -t nat -D PREROUTING -i enp1s0 -p udp --dport "$ENTRY_PORT" -j DNAT --to-destination "$VPN_IP:$EXIT_PORT" 2>/dev/null || true
iptables -D FORWARD -p udp -d "$VPN_IP" --dport "$EXIT_PORT" -j ACCEPT 2>/dev/null || true
iptables -t nat -D POSTROUTING -p udp -d "$VPN_IP" --dport "$EXIT_PORT" -j MASQUERADE 2>/dev/null || true

# Apply iptables rules
iptables -t nat -A PREROUTING -i enp1s0 -p udp --dport "$ENTRY_PORT" -j DNAT --to-destination "$VPN_IP:$EXIT_PORT"
iptables -A FORWARD -p udp -d "$VPN_IP" --dport "$EXIT_PORT" -j ACCEPT
iptables -t nat -A POSTROUTING -p udp -d "$VPN_IP" --dport "$EXIT_PORT" -j MASQUERADE

# Allow the entry port through UFW
ufw allow "$ENTRY_PORT"/udp

echo "Iptables rules applied successfully!"
echo "Forwarding from port $ENTRY_PORT to $VPN_IP:$EXIT_PORT"
