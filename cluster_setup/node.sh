#!/bin/bash

if [[ -f $SCRIPT_DIR/cluster.env ]]
then
  . $SCRIPT_DIR/cluster.env
else
  read -p "Enter cluster name: " CLUSTER_NAME
  read -p "Enter cluster endpoint ip: " CLUSTER_ENDPOINT
  echo "CLUSTER_NAME=$CLUSTER_NAME" >> "$SCRIPT_DIR/cluster.env"
  echo "CLUSTER_ENDPOINT=$CLUSTER_ENDPOINT" >> "$SCRIPT_DIR/cluster.env"
fi

#cluster hostname
sudo echo "$CLUSTER_ENDPOINT $CLUSTER_NAME" | sudo tee -a /etc/hosts > /dev/null

#update upgrade
sudo apt-get update
sudo apt-get upgrade -y

#network
sudo cat << EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.ipv4.ip_forward = 1
EOF

sudo deb-systemd-invoke restart procps.service

#install containerd
#install docker
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install containerd.io -y

sudo mkdir -p /etc/containerd

sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
sudo sed -e 's/sandbox_image = .*/sandbox_image = "registry.k8s.io\/pause:3.9"/g' -i /etc/containerd/config.toml

sudo systemctl restart containerd

#install kubernetes

#dependencies
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

#keyring
# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

#package
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
