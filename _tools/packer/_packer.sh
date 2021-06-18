#!/usr/bin/env bash

set -e -o pipefail
set +x

# Check for required tools
declare -a req_tools=("packer" "hcl2json" "sed" "curl" "jq")
for tool in "${req_tools[@]}"; do
  if ! command -v "$tool" > /dev/null; then
    fail "It looks like '${tool}' is not installed; please install it and run this setup script again."
    exit 1
  fi
done

# functions
info() {
  printf "\r\033[00;35m$1\033[0m\n"
}

success() {
  printf "\r\033[00;32m$1\033[0m\n"
}

fail() {
  printf "\r\033[0;31m$1\033[0m\n"
}

warm() {
  printf "\r\033[0;33m$1\033[0m\n"
}

# Variables
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

PACKER_ONLY="amazon-ebs.source"
PACKER_EXTRA_ARGS="${*}"
PACKER_TEMPLATE_DIR="$SCRIPT_DIR/templates"
PACKER_OUTPUT_FILE="$(pwd)/packer.out"
PACKER_CACHE_DIR="packer_cache"

VAGRANT_SSH_PRIVATE_KEY="$HOME/.vagrant.d/insecure_private_key"
VAGRANT_BOX_HOME="$HOME/.vagrant.d/boxes"
VAGRANT_BOX_DOWNLOAD="$HOME/.vagrant.d/downloaded"

# vagrant check
CHECKPOINT_DISABLE=1
VAGRANT_CHECKPOINT_DISABLE=1

PACKER_VARS_FILE="$(pwd)/packer.auto.pkrvars.hcl"
PACKER_TEMPLATE="$(cat $PACKER_VARS_FILE | hcl2json | jq -r -c .template)"
PACKER_TEMPLATE_PATH="${PACKER_TEMPLATE_DIR}/${PACKER_TEMPLATE}"

if [[ ! -d "${PACKER_TEMPLATE_PATH}" ]] ; then
  fail "Incorrect folder for packer templates : ${PACKER_TEMPLATE_PATH}"
  exit 1
fi


# Validate packer
if [ "$1" = "init" ]; then
  packer init "${PACKER_TEMPLATE_PATH}" | tee -i "${PACKER_OUTPUT_FILE}"
  exit 0
fi

# Validate packer
if [ "$1" = "validate" ]; then
  packer validate \
  -var-file "$PACKER_VARS_FILE" \
  "${PACKER_TEMPLATE_PATH}" | tee -i "${PACKER_OUTPUT_FILE}"
  exit 0
fi

# Inspect templates packer
if [ "$1" = "inspect" ]; then
  packer validate \
  -var-file="$PACKER_VARS_FILE" \
  "${PACKER_TEMPLATE_PATH}" | tee -i "${PACKER_OUTPUT_FILE}"
  exit 0
fi

# Build local part
if [ "$1" = "-local" ]; then

  if [ -z "$2" ] || [ "$2" != "qemu" ]; then

    info "==> starting build box"

    BOX_NAME="$(cat ${PACKER_TEMPLATE_PATH}/variables.pkr.hcl | hcl2json | jq -r -c .variable.box_name[].default)"
    BOX_OS="${BOX_NAME%%/*}"
    BOX_DISTRIB="${BOX_NAME##*/}"
    PACKER_ONLY="virtualbox-ovf"

    # info "==> packer: BOX_OS=${BOX_OS}"
    # info "==> packer: BOX_NAME=${BOX_NAME}"
    # info "==> packer: BOX_DISTRIB=${BOX_DISTRIB}"

    # Get some metadata box from cloud repositories
    # To find/fix somes URL boxes : try https://app.vagrantup.com/boxes/search
    case ${BOX_OS} in
      debian)
        METADATA=$(curl -s https://salsa.debian.org/cloud-team/vagrant-boxes/raw/master/packer-virtualbox-vagrant/virtualbox-"${BOX_DISTRIB%%64}".SHA256SUM)
        BOX_CHECKSUM=$(echo "$METADATA" | cut -d' ' -f1)
        BOX_VERSION=$(echo "$METADATA" | cut -d' ' -f3)
        BOX_FILENAME=$(echo "$METADATA" | cut -d' ' -f2)
        BOX_URL="https://app.vagrantup.com/${BOX_OS}/boxes/${BOX_DISTRIB}/versions/${BOX_VERSION}/providers/virtualbox.box"
      ;;
      bento | generic | roboxes)
        BOX_VERSION="$(cat ${PACKER_TEMPLATE_PATH}/variables.pkr.hcl | hcl2json | jq -r -c .variable.box_version[].default)"
        BOX_FILENAME="virtualbox.box"
        BOX_URL="https://app.vagrantup.com/${BOX_OS}/boxes/${BOX_DISTRIB}/versions/${BOX_VERSION}/providers/virtualbox.box"
        echo "BOX_URL: $BOX_URL"
      ;;
      ubuntu)
        BOX_VERSION="$(jq -r -c .variables.box_version "${PACKER_TEMPLATE_PATH}")"
        METADATA=$(curl -s https://cloud-images.ubuntu.com/"${BOX_DISTRIB%%64}"/"${BOX_VERSION}"/SHA256SUMS)
        BOX_CHECKSUM=$(echo "$METADATA" | cut -d' ' -f1 | sed -n 5p)
        BOX_FILENAME=$(echo "$METADATA" | cut -d' ' -f2 | sed -n 5p)
        BOX_FILENAME=${BOX_FILENAME:1}
        BOX_URL="https://cloud-images.ubuntu.com/${BOX_DISTRIB%%64}/${BOX_VERSION}/${BOX_FILENAME}"
      ;;
    esac

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
      --force  --name "$BOX_NAME" \
      --checksum "$BOX_CHECKSUM" \
      --checksum-type "sha256" \
      "$BOX_FULLPATH"

    VAGRANT_BOX_FOLDER="$(realpath "$VAGRANT_BOX_HOME"/"$BOX_OS"-VAGRANTSLASH-"$BOX_DISTRIB"/0/virtualbox)"
    OVF_CHECKSUM="$(sha256sum "$VAGRANT_BOX_FOLDER"/box.ovf | awk '{ print $1}')"
    BOX_BASE_MAC="$(sed -n 's/.*base_mac = "\(.*\)"/\1/p' "$VAGRANT_BOX_FOLDER"/Vagrantfile)"
    PACKER_ONLY="virtualbox-ovf"
    PACKER_EXTRA_ARGS="${*:2}"

    info "==> packer: SSH command: ssh -i ~/.vagrant.d/insecure_private_key -p 62222 vagrant@localhost"
    info "==> packer: BOX_VERSION=${BOX_VERSION}"
    info "==> packer: BOX_OS=${BOX_OS}"
    info "==> packer: BOX_NAME=${BOX_NAME}"
    info "==> packer: BOX_FILENAME=${BOX_FILENAME}"
    info "==> packer: BOX_DISTRIB=${BOX_DISTRIB}"
    info "==> packer: VAGRANT_BOX_FOLDER=${VAGRANT_BOX_FOLDER}"
    info "==> packer: BOX_BASE_MAC=${BOX_BASE_MAC}"
    info "==> packer: BOX_CHECKSUM=${BOX_CHECKSUM}"
    info "==> packer: OVF_CHECKSUM=${OVF_CHECKSUM}"

  else
    PACKER_EXTRA_ARGS="${*:3}"
    PACKER_ONLY="qemu.debian"
  fi
fi

# build image with packer
info "==> packer: PACKER_ONLY=${PACKER_ONLY}"
info "==> packer: PACKER_OUTPUT_FILE=${PACKER_OUTPUT_FILE}"
info "==> packer: PACKER_EXTRA_ARGS=${PACKER_EXTRA_ARGS}"

if [ -z "${PACKER_EXTRA_ARGS}" ]; then
  PACKER_EXTRA_ARGS="--"
fi

# Initialise packer template
packer init "${PACKER_TEMPLATE_PATH}"

packer build -force \
-only="${PACKER_ONLY}" \
-var-file="$PACKER_VARS_FILE" \
-var "box_folder=${VAGRANT_BOX_FOLDER}" \
-var "box_base_mac=${BOX_BASE_MAC}" \
-var "box_checksum=${OVF_CHECKSUM}" \
-var "vagrant_ssh_private_key=${VAGRANT_SSH_PRIVATE_KEY}" \
"${PACKER_EXTRA_ARGS}" \
"${PACKER_TEMPLATE_PATH}" | tee -i "${PACKER_OUTPUT_FILE}"
