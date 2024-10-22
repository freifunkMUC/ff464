#!/bin/bash

# Set up LLA on v4-0
sysctl -w net.ipv6.conf.v4-0.disable_ipv6=0
ip link set v4-0 down
ip addr flush v4-0
ip link set v4-0 up

# Set up LLA on v6-0
sysctl -w net.ipv6.conf.v6-0.disable_ipv6=0
ip link set v6-0 down
ip addr flush v6-0
ip link set v6-0 up

# Set up LLA on tunnel0
sysctl -w net.ipv6.conf.tunnel0.disable_ipv6=0
ip link set tunnel0 down
ip addr flush tunnel0
ip link set tunnel0 up

# Set up address on plat-v6-0
sysctl -w net.ipv6.conf.plat-v6-0.disable_ipv6=0
ip link set plat-v6-0 down
ip addr flush plat-v6-0
ip link set plat-v6-0 up
ip addr add 2001:db8:f00::2/64 dev plat-v6-0

# Set up address on plat-v4-0
ip link set plat-v4-0 down
ip addr flush plat-v4-0
ip link set plat-v4-0 up
ip addr add 198.51.100.2/29 dev plat-v4-0

# Enable IPv6 forwarding
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.conf.default.forwarding=1
sysctl -w net.ipv6.conf.v6-0.forwarding=1
sysctl -w net.ipv6.conf.tunnel0.forwarding=1
sysctl -w net.ipv6.conf.plat-v6-0.forwarding=1

# Enable route to PLAT
ip route add 64:ff9b::/96 via 2001:db8:f00::1 dev plat-v6-0

# Set up FRR
sysctl -w vm.overcommit_memory=1
sed -i -e 's/^bgpd=no/bgpd=yes/' /etc/frr/daemons
cat <<EOF > /etc/frr/frr.conf
router bgp 4200000010
  bgp router-id 1.2.3.4
  bgp bestpath as-path multipath-relax
  no bgp ebgp-requires-policy
  no bgp default ipv4-unicast

  neighbor v4-0 interface v6only remote-as external
  neighbor v6-0 interface v6only remote-as external
  neighbor tunnel0 interface v6only remote-as external

  address-family ipv4 unicast
    network 198.51.100.0/29

    neighbor v4-0 activate
  exit-address-family

  address-family ipv6 unicast
    network 64:ff9b::/96

    neighbor v6-0 activate
    neighbor tunnel0 activate
  exit-address-family
EOF
/usr/lib/frr/frrinit.sh start

trap "echo Shutting down; exit 0" SIGTERM SIGINT SIGKILL
/bin/sleep infinity &
wait
