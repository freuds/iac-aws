#!/bin/bash
set -xe

sed -i -- "s#__S3_VAULT_BUCKET__#${ s3_vault_bucket }#" /opt/authorized_keys_command.sh
sed -i -- "s#__S3_VAULT_BUCKET__#${ s3_vault_bucket }#" /opt/import_users.sh
sed -i -- "s#__ELASTIC_IP_BASTION__#${ eip_bastion }#" /opt/attach_eip.sh

/opt/attach_eip.sh
/opt/import_users.sh