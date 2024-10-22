FROM ligato/vpp-base:24.06

ADD startup.conf startup.cmd /etc/vpp/

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT /entrypoint.sh
