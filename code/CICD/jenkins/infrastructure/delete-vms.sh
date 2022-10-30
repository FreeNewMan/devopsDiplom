#!/bin/bash

set -e

function delete_vm {
  local NAME=$1
  $(yc compute instance delete --name="$NAME")
}

delete_vm "jenkins-master"
delete_vm "jenkins-agent"
#delete_vm "node2"
