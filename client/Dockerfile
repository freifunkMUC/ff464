FROM ubuntu:24.04

RUN apt update && apt install -y iproute2 tcpdump dhcpcd netcat-openbsd iputils-ping traceroute mtr

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT /entrypoint.sh
