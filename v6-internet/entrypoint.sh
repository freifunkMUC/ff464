#!/bin/bash

# Set up LLA on v6-0
sysctl -w net.ipv6.conf.v6-0.disable_ipv6=0
ip link set v6-0 down
ip addr flush v6-0
ip link set v6-0 up

# Set up example service with "public" address
ip link add example-host type dummy
ip a add 2001:db8:dead:beef::1/128 dev example-host
ip link set example-host up

# Set up FRR
sysctl -w vm.overcommit_memory=1
sed -i -e 's/^bgpd=no/bgpd=yes/' /etc/frr/daemons
cat <<EOF > /etc/frr/frr.conf
router bgp 4200000030
  bgp router-id 1.2.3.4
  bgp bestpath as-path multipath-relax
  no bgp ebgp-requires-policy
  no bgp default ipv4-unicast

  neighbor v6-0 interface v6only remote-as external

  address-family ipv6 unicast
    network 2001:db8:dead:beef::1/128

    neighbor v6-0 activate
  exit-address-family
EOF
/usr/lib/frr/frrinit.sh start

trap "echo Shutting down; exit 0" SIGTERM SIGINT SIGKILL
while true
do
    echo Success | nc -6Nl 1234
done
