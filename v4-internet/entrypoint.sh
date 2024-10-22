#!/bin/bash

# Set up LLA on v4-0
sysctl -w net.ipv6.conf.v4-0.disable_ipv6=0
ip link set v4-0 down
ip addr flush v4-0
ip link set v4-0 up

# Set up example service with "public" address
ip link add example-host type dummy
ip a add 192.0.2.1/32 dev example-host
ip link set example-host up

# Set up FRR
sysctl -w vm.overcommit_memory=1
sed -i -e 's/^bgpd=no/bgpd=yes/' /etc/frr/daemons
cat <<EOF > /etc/frr/frr.conf
router bgp 4200000020
  bgp router-id 1.2.3.4
  bgp bestpath as-path multipath-relax
  no bgp ebgp-requires-policy
  no bgp default ipv4-unicast

  neighbor v4-0 interface v6only remote-as external

  address-family ipv4 unicast
    network 192.0.2.1/32

    neighbor v4-0 activate
  exit-address-family
EOF
/usr/lib/frr/frrinit.sh start

trap "echo Shutting down; exit 0" SIGTERM SIGINT SIGKILL
while true
do
    echo Success | nc -4Nl 1234
done
