FROM ubuntu:20.04

RUN apt update && apt install -y vim iproute2 iputils-ping tcpdump iptables dnsutils curl quagga telnet
EXPOSE 2601 2604
COPY sleep.sh /root/sleep.sh
COPY start-ospf-bgp.sh /root/start.sh
CMD /root/start.sh