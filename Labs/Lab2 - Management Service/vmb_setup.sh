#!/bin/sh

# Build docker images
echo "Build docker images"
sudo docker build --tag netubuntu ~/baseimage
sudo docker build --tag serverworkercontainer ~/serverworkercontainer/
sudo docker build --tag servercontainer ~/servercontainer

# Cleanup and setup
echo "Docker cleanup"
sudo docker rm -f client server server_worker1 server_worker2 router
sudo docker network rm client_net server_net
echo "Enable interfaces"
sudo ip l set ens19 up
sudo ip l set ens20 up

# Networks
echo "Create macvlans"
sudo docker network create -d macvlan --subnet=10.0.1.0/24 --gateway=10.0.1.1 -o parent=ens19 client_net
sudo docker network create -d macvlan --subnet=10.0.2.0/24 --gateway=10.0.2.1 -o parent=ens20 server_net
sudo docker network create -d macvlan --subnet=10.0.3.0/24 --gateway=10.0.3.1 -o parent=eth0  monit_net

# Router
echo "Start router container"
sudo docker run -d --net client_net --ip 10.0.1.254 --cap-add=NET_ADMIN --name router netubuntu
sudo docker network connect server_net router --ip 10.0.2.254
sudo docker network connect monit_net router --ip 10.0.3.254

# Server
echo "Start server containers"
sudo docker run -d --net server_net --ip 10.0.2.101 --cap-add=NET_ADMIN --name server_worker1 serverworkercontainer
sudo docker run -d --net server_net --ip 10.0.2.102 --cap-add=NET_ADMIN --name server_worker2 serverworkercontainer
sudo docker run -d --net server_net --ip 10.0.2.100 --cap-add=NET_ADMIN --name server servercontainer
## Routing
sudo docker exec server /bin/bash -c 'ip r del default via 10.0.2.1'
sudo docker exec server /bin/bash -c 'ip r a 10.0.1.0/24 via 10.0.2.254'

# Monitoring
echo "Start nagios"
docker run --name nagios -p 0.0.0.0:8080:80 manios/nagios:latest

# Client
#echo "Start client container"
#sudo docker run -d --net client_net --ip 10.0.1.100 --cap-add=NET_ADMIN --name client -v "$(pwd)":/browsertime sitespeedio/browsertime http://10.0.2.100
## Routing
#sudo docker exec client /bin/bash -c 'ip r del default via 10.0.1.1'
#sudo docker exec client /bin/bash -c 'ip r a 10.0.2.0/24 via 10.0.1.254'

# Testing
#echo "Test"
#sudo docker exec client curl 10.0.2.100
