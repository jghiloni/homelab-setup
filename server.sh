#!/usr/bin/env bash

set -e

INDEX=$1

sudo hostname k3s-server-$INDEX

export newIP="192.168.65.${INDEX}/18"

sudo -E yq -i '.network.ethernets.ens18.addresses[0] = env(newIP)' /etc/netplan/50-cloud-init.yaml

curl -sfL https://get.k3s.io | K3S_TOKEN=$2 sh -s - server --server "https://192.168.65.1:6443" --disable=service-lb,traefik

sudo chmod 644 /etc/rancher/k3s/k3s.yaml

kubectl get nodes

sudo rm -vf /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server

sudo reboot
