#!/bin/sh

# Cleanup and setup
echo "Docker cleanup"
sudo docker rm -f client
sudo docker network rm client_net
echo "Enable interfaces"
sudo ip l set ens19 up
sudo ip l set ens20 up

# Networks
echo "Create macvlans"
sudo docker network create -d macvlan --subnet=10.0.1.0/24 --gateway=10.0.1.1 -o parent=ens19 client_net

# Client
echo "Start client container"
sudo docker run -d --net client_net --ip 10.0.1.101 --cap-add=NET_ADMIN --name client -v "$(pwd)":/browsertime sitespeedio/browsertime http://10.0.2.100

# Routing on client and server
echo "Setup routing on client and server containers"
sudo docker exec client /bin/bash -c 'ip r del default via 10.0.1.1'
sudo docker exec client /bin/bash -c 'ip r a 10.0.2.0/24 via 10.0.1.254'

# Testing
echo "Test"
sudo docker exec client curl 10.0.2.100