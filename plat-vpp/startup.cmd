# Set up interfaces by attaching to veths
create host-interface name plat-v4-0
create host-interface name plat-v6-0
set int state host-plat-v4-0 up
set int state host-plat-v6-0 up

# Set interface IPs and default routes
set int ip address host-plat-v4-0 198.51.100.1/29
set int ip address host-plat-v6-0 2001:db8:f00::1/64
ip route add ::/0 via 2001:db8:f00::2
ip route add 0.0.0.0/0 via 198.51.100.2

# Configure NAT64
nat64 plugin enable
set int nat64 in host-plat-v6-0
set int nat64 out host-plat-v4-0
nat64 add prefix 64:ff9b::/96
nat64 add pool address 198.51.100.3 - 198.51.100.6
