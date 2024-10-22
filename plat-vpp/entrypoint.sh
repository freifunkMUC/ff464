#!/bin/bash

# Flush veth interfaces, all traffic is handled by VPP
ip addr flush plat-v4-0
ip addr flush plat-v6-0

# Start VPP
exec vpp -c /etc/vpp/startup.conf
