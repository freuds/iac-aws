#!/bin/bash
set -ex
# Remove Ansible
sudo rm -rf /etc/ansible/roles/*
sudo pip3 uninstall ansible --yes
sudo apt-get --yes --purge --autoremove remove python3-pip


# "sudo apt-get autoremove -y",
# "sudo apt-get clean",
# "sudo rm -rf /tmp/*",
# "sudo history -c && sudo history -w" // Clear bash history
