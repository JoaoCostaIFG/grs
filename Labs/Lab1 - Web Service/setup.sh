#!/bin/sh

# Build docker images
echo "Build docker images"
sudo docker build --tag netubuntu ~/baseimage
sudo docker build --tag servercontainer ~/servercontainer

# Cleanup and setup
echo "Docker cleanup"
sudo docker rm -f client server router
sudo docker network rm client_net server_net
echo "Enable interfaces"
sudo ip l set ens19 up
sudo ip l set ens20 up

# Networks
echo "Create macvlans"
sudo docker network create -d macvlan --subnet=10.0.1.0/24 --gateway=10.0.1.1 -o parent=ens19 client_net
sudo docker network create -d macvlan --subnet=10.0.2.0/24 --gateway=10.0.2.1 -o parent=ens20 server_net

# Router
echo "Start router container"
sudo docker run -d --net client_net --ip 10.0.1.254 --cap-add=NET_ADMIN --name router netubuntu
sudo docker network connect server_net router --ip 10.0.2.254

# Client and server
echo "Start server container"
sudo docker run -d --net server_net --ip 10.0.2.100 --cap-add=NET_ADMIN --name server servercontainer
echo "Start client container"
sudo docker run -d --net client_net --ip 10.0.1.100 --cap-add=NET_ADMIN --name client -v "$(pwd)":/browsertime sitespeedio/browsertime http://10.0.2.100

# Routing on client and server
echo "Setup routing on client and server containers"
sudo docker exec client /bin/bash -c 'ip r del default via 10.0.1.1'
sudo docker exec client /bin/bash -c 'ip r a 10.0.2.0/24 via 10.0.1.254'
sudo docker exec server /bin/bash -c 'ip r del default via 10.0.2.1'
sudo docker exec server /bin/bash -c 'ip r a 10.0.1.0/24 via 10.0.2.254'

# Testing
echo "Test"
sudo docker exec client curl 10.0.2.100