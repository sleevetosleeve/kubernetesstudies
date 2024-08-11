#!/bin/bash

if [[ $EUID -eq 0 ]]; then
  echo "This script must NOT be run as root" 1>&2
  exit 1
fi

SCRIPT_DIR="$(dirname "$0")"

#install stuff
. $SCRIPT_DIR/node.sh

#join cluster
sudo $SCRIPT_DIR/minion.sh

#setup kubectl
mkdir -p $HOME/.kube
cat $SCRIPT_DIR/kubeconfig > $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#bash compleation
$SCRIPT_DIR/bash_compleation.sh