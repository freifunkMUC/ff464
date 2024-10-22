#!/bin/bash

sysctl -w net.ipv6.conf.lan0.disable_ipv6=0

ip link set lan0 down
ip addr flush lan0
ip link set lan0 up

dhcpcd lan0

trap "echo Shutting down; exit 0" SIGTERM SIGINT SIGKILL
/bin/sleep infinity &
wait
