#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive
# Update packages
sudo apt-get -qq update --yes
# Install Python3 pip
sudo apt-get -qq install --yes python3-pip python-apt aptitude cloud-init
# Print pip3 version
pip3 --version
# Install Ansible via pip3
sudo pip3 install ansible
# Print Ansible version
ansible --version