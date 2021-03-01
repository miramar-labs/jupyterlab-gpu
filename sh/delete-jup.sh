#!/usr/bin/env bash

UZERID=`whoami`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd $DIR/../../cluster/local.esxi
ansible-playbook ../../jup/undeploy.yml
popd