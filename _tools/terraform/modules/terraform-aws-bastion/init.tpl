#!/bin/bash
set -xe

sed -i -- "s#__ELASTIC_IP_BASTION__#${ eip_bastion }#" /opt/attach_eip.sh
/opt/attach_eip.sh ${ region }

sed -i -- "s#__SSH_PORT__#${ ssh_port }#" /etc/ssh/sshd_config
systemctl restart sshd
