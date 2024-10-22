Containers:
- Client: Represents typical client device, sees typical dual-stack with private IPv4 and public IPv6
- Router: Represents FF node, routes IPv6 and performs CLAT 4->6 translation for its clients
  - Variant 1: `router-jool`, uses [Jool](https://nicmx.github.io/Jool/en/index.html) SIIT for translation (requires jool kernel modules loaded on the host)
  - Variant 2: `router-nat46`, uses [nat46](https://github.com/ayourtch/nat46) kernel module for translation (requires nat46 to be loaded on the host)
- PLAT: Performs NAT64 translation using a public IPv4 pool
  - Variant 1: `plat-jool`, uses [Jool](https://nicmx.github.io/Jool/en/index.html) for translation (requires jool kernel modules loaded on the host)
  - Variant 2: `plat-vpp`, uses [VPP](https://s3-docs.fd.io/vpp/24.10/) for translation
    - Note that the setup here is kept very simple, and as a result shows poor performance. A proper setup would use polling mode, pinned worker threads and TAP interfaces to connect to the kernel network stack (or even better, DPDK on hardware).
- Gateway: Represents FF gateway, is connected to Router, PLAT and Internet, routes between them
- Internet: Represents internet services, answers to pings and TCP connections to port 1234

IPv4 ranges:
- `192.0.2.1/32`: Example internet service
- `192.168.42.0/24`: Client LAN
- `198.51.100.0/29`: Public FF IPv4 range
  - `198.51.100.1`: PLAT service
  - `198.51.100.2`: Gateway
  - `198.51.100.3-6`: Public NAT64 pool

IPv6 ranges:
- `2001:db8:dead:beef::1/128`: Example internet service
- `2001:db8:1234::/64`: Client LAN
- `2001:db8:1234:64::/96`: Router CLAT prefix
- `2001:db8:f00::/64`: PLAT/Gateway connection
  - `2001:db8:f00::1`: PLAT service
  - `2001:db8:f00::2`: Gateway
- `64:ff9b::/96`: NAT64 prefix
