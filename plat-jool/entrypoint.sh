#!/bin/bash

# Set up address on plat-v6-0
sysctl -w net.ipv6.conf.plat-v6-0.disable_ipv6=0
ip link set plat-v6-0 down
ip addr flush plat-v6-0
ip link set plat-v6-0 up
ip addr add 2001:db8:f00::1/64 dev plat-v6-0

# Set up address on plat-v4-0
ip link set plat-v4-0 down
ip addr flush plat-v4-0
ip link set plat-v4-0 up
ip addr add 198.51.100.1/29 dev plat-v4-0

# Enable IPv6 forwarding
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.conf.default.forwarding=1
sysctl -w net.ipv6.conf.plat-v6-0.forwarding=1

# Setup default routes to gateway
ip route add ::/0 via 2001:db8:f00::2
ip route add default via 198.51.100.2

# Set up Jool
jool instance add --netfilter --pool6 64:ff9b::/96
sysctl net.ipv4.ip_local_port_range="1 65535"
for ip in 198.51.100.3 198.51.100.4 198.51.100.5 198.51.100.6
do
  jool pool4 add --tcp $ip 1-65535
  jool pool4 add --udp $ip 1-65535
  jool pool4 add --icmp $ip 1-65535

  # Needed so that we respond to ARP
  ip addr add $ip/29 dev plat-v4-0
done

/bin/sleep infinity
