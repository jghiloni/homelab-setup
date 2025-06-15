#!/usr/bin/env bash

set -e

sudo apt -y update && sudo apt -y upgrade && sudo apt -y install qemu-guest-agent

sudo systemctl start qemu-guest-agent

INDEX=$1

sudo hostname k3s-server-$INDEX

wget https://github.com/mikefarah/yq/releases/download/v4.45.4/yq_linux_amd64
sudo install -m0755 yq_linux_amd64 /usr/bin/yq
rm yq_linux_amd64

export newIP="192.168.65.${INDEX}/18"

sudo  yq -i '.network.ethernets.ens18.addresses[0] = env(newIP)' /etc/netplan/50-cloud-init.yaml

echo "192.168.1.20:/data /data  nfs      defaults    0       0" | sudo tee -a /etc/fstab

curl -sfL https://get.k3s.io | K3S_TOKEN=$2 sh -s - server --server "https://192.168.65.1:6443" --disable=service-lb,traefik

sudo chmod 644 /etc/rancher/k3s/k3s.yaml

kubectl get nodes

sudo rm -vf /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server

sudo reboot
