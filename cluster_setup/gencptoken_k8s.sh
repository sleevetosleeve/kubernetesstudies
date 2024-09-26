#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"
. $SCRIPT_DIR/cluster.env

tok=$(sudo kubeadm token create | tr -d '\n')
hash=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //' | tr -d '\n')
key=$(sudo kubeadm init phase upload-certs --upload-certs | tail -1 | tr -d '\n')

echo "sudo kubeadm join $CLUSTER_NAME:6443 --token $tok --discovery-token-ca-cert-hash sha256:$hash --control-plane --certificate-key $key" > $SCRIPT_DIR/controlplane.sh

chmod a+x $SCRIPT_DIR/controlplane.sh