#!/bin/bash
set -xe

# Inject SSH AuthorizedKeys scripts for SSH to work
sed -i -- "s#__S3_VAULT_BUCKET__#${ s3_vault_bucket }#" /opt/authorized_keys_command.sh
sed -i -- "s#__S3_VAULT_BUCKET__#${ s3_vault_bucket }#" /opt/import_users.sh

# Sync linux users  with aws-users.auto.json
/opt/import_users.sh

# Inject AWS Resolver
sed -i -- "s#__AWS_RESOLVER_IP__#${ aws_resolver_ip }#" /etc/haproxy/02-resolvers.cfg