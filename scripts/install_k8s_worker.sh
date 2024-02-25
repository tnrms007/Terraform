#!/bin/bash

######### ** FOR MASTER NODE ** #########

hostname ksgcluster_worker${worker_number}
echo "ksgcluster_worker${worker_number}" > /etc/hostname

apt update
apt install apt-transport-https ca-certificates curl software-properties-common -y 
apt install python3.11 -y 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

#Installing Docker
apt update
apt-cache policy docker-ce
apt install docker-ce -y
apt install awscli -y
#Be sure to understand, if you follow official Kubernetes documentation, in Ubuntu 20 it does not work, that is why, I did modification to script
#Adding Kubernetes repositories

#Next 2 lines are different from official Kubernetes guide, but the way Kubernetes describe step does not work
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
echo "deb https://packages.cloud.google.com/apt kubernetes-xenial main" > /etc/apt/sources.list.d/kurbenetes.list

#Turn off swap
swapoff -a

useradd ksg -m -s /bin/bash -G ksg
echo "ksg:2024Test@#" | chpasswd
cp /etc/sudoers /etc/sudoers.back
echo 'ksg ALL=(ALL) NOPASSWD:ALL' | tee -a /etc/sudoers
