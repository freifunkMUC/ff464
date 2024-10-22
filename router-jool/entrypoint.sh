#!/bin/bash

# Set up LLA on lan0
sysctl -w net.ipv6.conf.lan0.disable_ipv6=0
ip link set lan0 down
ip addr flush lan0
ip link set lan0 up

# Set up LLA on tunnel0
sysctl -w net.ipv6.conf.tunnel0.disable_ipv6=0
ip link set tunnel0 down
ip addr flush tunnel0
ip link set tunnel0 up

# Enable IPv6 forwarding
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.conf.default.forwarding=1
sysctl -w net.ipv6.conf.lan0.forwarding=1
sysctl -w net.ipv6.conf.tunnel0.forwarding=1

# Add gateway IPs
ip a add 192.168.42.1/24 dev lan0
ip a add 2001:db8:1234::1/64 dev lan0

# Setup DHCP
dnsmasq --no-daemon --interface=lan0 --dhcp-range=192.168.42.100,192.168.42.199,255.255.255.0 &

# Setup radvd
cat <<EOF > /etc/radvd.conf
interface lan0
{
  AdvSendAdvert on;

  prefix 2001:db8:1234::/64
  {
    AdvAutonomous on;
    AdvOnLink on;
  };
};
EOF
radvd -m stderr

# Set up FRR
sysctl -w vm.overcommit_memory=1
sed -i -e 's/^bgpd=no/bgpd=yes/' /etc/frr/daemons
cat <<EOF > /etc/frr/frr.conf
router bgp 4200000000
  bgp router-id 1.2.3.4
  bgp bestpath as-path multipath-relax
  no bgp ebgp-requires-policy
  no bgp default ipv4-unicast

  neighbor tunnel0 interface v6only remote-as external

  address-family ipv6 unicast
    network 2001:db8:1234::/64
    network 2001:db8:1234:64::/96

    neighbor tunnel0 activate
  exit-address-family
EOF
/usr/lib/frr/frrinit.sh start

# Set up Jool
ip r add 2001:db8:1234:64::/96 dev lo
jool_siit instance add --netfilter --pool6 64:ff9b::/96
# Jool doesn't support different prefixes for source and destination,
# so we need to add a more-specific entry for the local prefix :(
jool_siit eamt add 192.168.42.0/24 2001:db8:1234:64::192.168.42.0/120

trap "echo Shutting down; exit 0" SIGTERM SIGINT SIGKILL
wait
