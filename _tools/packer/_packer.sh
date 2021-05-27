#!/bin/bash
set -e -o pipefail
set +x

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

PACKER_ONLY="amazon-ebs"
PACKER_EXTRA_ARGS="${*}"
PACKER_VARS_FILE="$(pwd)/packer.var.json"
PACKER_TEMPLATE="$(jq -r -c .template "$PACKER_VARS_FILE")"
PACKER_TEMPLATE_PATH="$SCRIPT_DIR/templates/$PACKER_TEMPLATE.json"
PACKER_OUTPUT_FILE="$(pwd)/packer.out"

VAGRANT_SSH_PRIVATE_KEY="$HOME/.vagrant.d/insecure_private_key"
VAGRANT_BOX_HOME="$HOME/.vagrant.d/boxes"
VAGRANT_BOX_DOWNLOAD="$HOME/.vagrant.d/downloaded"

export PACKER_CACHE_DIR="/tmp/packer_cache"

if [ "$1" = "-local" ]; then
  BOX_NAME="$(jq -r -c .variables.box_name "$PACKER_TEMPLATE_PATH")"
  BOX_OS="${BOX_NAME%%/*}"
  BOX_DISTRIB="${BOX_NAME##*/}"

  # Get some metadata box from cloud repositories
  # To find/fix somes URL boxes : try https://app.vagrantup.com/boxes/search
  case ${BOX_OS} in
    debian)
      METADATA=$(curl -s https://salsa.debian.org/cloud-team/vagrant-boxes/raw/master/packer-v
irtualbox-vagrant/virtualbox-"${BOX_DISTRIB%%64}".SHA256SUM)
      BOX_CHECKSUM=$(echo "$METADATA" | cut -d' ' -f1)
      BOX_VERSION=$(echo "$METADATA" | cut -d' ' -f3)
      BOX_FILENAME=$(echo "$METADATA" | cut -d' ' -f2)
      BOX_URL="https://app.vagrantup.com/${BOX_OS}/boxes/${BOX_DISTRIB}/versions/${BOX_VERSION}/providers/virtualbox.box"
    ;;
    bento | generic | roboxes)
      BOX_VERSION="$(jq -r -c .variables.box_version "${PACKER_TEMPLATE_PATH}")"
      BOX_FILENAME="virtualbox.box"
      BOX_URL="https://app.vagrantup.com/${BOX_OS}/boxes/${BOX_DISTRIB}/versions/${BOX_VERSION}/providers/virtualbox.box"
    ;;
    ubuntu)

    ;;
  esac

  echo "==> packer: BOX_URL=${BOX_URL}"

  # download box part
  BOX_FULLPATH="${VAGRANT_BOX_DOWNLOAD}/${BOX_OS}-VAGRANTSLASH-${BOX_DISTRIB}/${BOX_VERSION}/${BOX_FILENAME}"
  BOX_FULLPATH_FOLDER="$(dirname "$BOX_FULLPATH")"

  # Create box folder if it doesn't exist
  [ ! -d "$BOX_FULLPATH_FOLDER" ] && mkdir -p "$BOX_FULLPATH_FOLDER"
  cd "$BOX_FULLPATH_FOLDER"

  if [ ! -f "$BOX_FULLPATH" ]; then
    curl -L "$BOX_URL" -o "$BOX_FILENAME"
  else
    # box already exist
    read -r -p "Replace existing box ? [y/N] : "
    case $REPLY in
      [yY])
        echo "Ok. let's replace the box"
        curl -L "$BOX_URL" -o "$BOX_FILENAME"
        ;;
      *)
        echo "Ok. let's keep the current box"
      ;;
    esac
  fi

  # Get checksum from file box if it don't exist yet
  [ -z "$BOX_CHECKSUM" ] && BOX_CHECKSUM=$(sha256sum "$BOX_FULLPATH" | cut -d' ' -f1)

  # add box into vagrant
  cd - &>/dev/null && \
  vagrant box add \
    --force --name "$BOX_NAME" \
    --checksum "$BOX_CHECKSUM" \
    --checksum-type "sha256" \
    "$BOX_FULLPATH"

  VAGRANT_BOX_FOLDER="$(realpath "$VAGRANT_BOX_HOME"/"$BOX_OS"-VAGRANTSLASH-"$BOX_DISTRIB"/0/virtualbox)"
  OVF_CHECKSUM="$(sha256sum "$VAGRANT_BOX_FOLDER"/box.ovf | awk '{ print $1}')"
  BOX_BASE_MAC="$(sed -n 's/.*base_mac = "\(.*\)"/\1/p' "$VAGRANT_BOX_FOLDER"/Vagrantfile)"
  PACKER_ONLY="virtualbox-ovf"
  PACKER_EXTRA_ARGS="${*:2}"

  echo "==> packer: SSH command: ssh -i ~/.vagrant.d/insecure_private_key -p 62222 vagrant@localhost"
  echo "==> packer: BOX_VERSION=${BOX_VERSION}"
  echo "==> packer: BOX_OS=${BOX_OS}"
  echo "==> packer: BOX_NAME=${BOX_NAME}"
  echo "==> packer: BOX_FILENAME=${BOX_FILENAME}"
  echo "==> packer: BOX_DISTRIB=${BOX_DISTRIB}"
  echo "==> packer: VAGRANT_BOX_FOLDER=${VAGRANT_BOX_FOLDER}"
  echo "==> packer: BOX_BASE_MAC=${BOX_BASE_MAC}"
  echo "==> packer: BOX_CHECKSUM=${BOX_CHECKSUM}"
  echo "==> packer: OVF_CHECKSUM=${OVF_CHECKSUM}"

fi # end if local

# build image with packer
echo "==> packer: PACKER_ONLY=${PACKER_ONLY}"
echo "==> packer: PACKER_OUTPUT_FILE=${PACKER_OUTPUT_FILE}"
echo "==> packer: PACKER_EXTRA_ARGS=${PACKER_EXTRA_ARGS}"

if [ -z "${PACKER_EXTRA_ARGS}" ]; then
  PACKER_EXTRA_ARGS="--"
fi

packer build -force \
  -only="${PACKER_ONLY}" \
  -var-file="$PACKER_VARS_FILE" \
  -var "box_folder=${VAGRANT_BOX_FOLDER}" \
  -var "box_base_mac=${BOX_BASE_MAC}" \
  -var "box_checksum=${OVF_CHECKSUM}" \
  -var "vagrant_ssh_private_key=${VAGRANT_SSH_PRIVATE_KEY}" \
  "${PACKER_EXTRA_ARGS}" \
  "${SCRIPT_DIR}/templates/${PACKER_TEMPLATE}.json" | tee -i "${PACKER_OUTPUT_FILE}"
