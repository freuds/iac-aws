#!/bin/bash -e
set -e

if [ -z "$1" ]; then
  exit 1
fi

SSH_PUB_KEY=$(curl -s https://__S3_VAULT_BUCKET__.s3.amazonaws.com/aws-users.auto.json | jq -r --arg USER "$1" '.[] | select(.bastion_user==$USER) | .ssh_public_key')

if [ "${SSH_PUB_KEY}" == "null" ]; then
  exit 1
else
  echo "${SSH_PUB_KEY}"
fi

