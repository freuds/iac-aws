#!/bin/sh
set -ex

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
SSH_USERS=$(curl -s https://__S3_VAULT_BUCKET__.s3.amazonaws.com/aws-users.auto.json | jq -r 'keys | .[]')

for row in ${SSH_USERS}; do
  if id -u "${row}" >/dev/null 2>&1; then
    echo "${row} exists"
  else
    /usr/sbin/adduser --disabled-password --gecos "" "${row}"
    echo "${row} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${row}"
    chmod 440 "/etc/sudoers.d/${row}"
  fi
done
