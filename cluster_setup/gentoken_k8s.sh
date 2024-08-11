#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"

kubeadm token create --print-join-command > $SCRIPT_DIR/minion.sh
chmod a+x $SCRIPT_DIR/minion.sh