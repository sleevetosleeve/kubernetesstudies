#!/bin/bash

if [[ $EUID -eq 0 ]]; then
  echo "This script must NOT be run as root" 1>&2
  exit 1
fi

SCRIPT_DIR="$(dirname "$0")"

#install stuff
. $SCRIPT_DIR/node.sh

#service
sudo systemctl enable --now kubelet

#init control plane
sudo kubeadm init --control-plane-endpoint $CLUSTER_NAME | sudo tee $SCRIPT_DIR/scripts/kubeadminit.out

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

cat $HOME/.kube/config > $SCRIPT_DIR/kubeconfig

kubeadm token create --print-join-command > $SCRIPT_DIR/minion.sh
chmod a+x $SCRIPT_DIR/minion.sh

#install cilium
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

cilium install

bash $SCRIPT_DIR/bash_compleation.sh

