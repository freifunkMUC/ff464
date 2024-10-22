FROM ubuntu:24.04

RUN apt update && apt install -y git build-essential pkg-config libnl-genl-3-dev libxtables-dev autoconf libtool cmake iproute2 frr iptables tcpdump

RUN git clone https://github.com/NICMx/Jool.git -b v4.1.13
WORKDIR /Jool
RUN ./autogen.sh && ./configure && make && make install

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT /entrypoint.sh
