#!/bin/bash
set -xe

sed -i -- "s#__ELASTIC_IP_BASTION__#${ eip_bastion }#" /opt/attach_eip.sh

/opt/attach_eip.sh ${ region }