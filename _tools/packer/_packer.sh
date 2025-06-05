#!/usr/bin/env bash

set -e -o pipefail
# set -x

# declare colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
MAGENTA="\e[35m"
CYAN="\e[36m"
# Reset all colors
RESET="\e[0m"

info() {
  printf "\r${MAGENTA}%s${RESET}\n" "$1"
}

msg() {
  printf "\r%s=${CYAN}%s${RESET}\n" "$1" "$2"
}

success() {
  printf "\r${GREEN}%s${RESET}\n" "$1"
}

fail() {
  printf "\r${RED}%s${RESET}\n" "$1"
  exit 1
}

warm() {
  printf "\r${YELLOW}%s${RESET}\n" "$1"
}

_help()
{
  # Display Help
  echo "Construction d'une image automatisée pour Jenkins via Packer."
  echo ""
  echo "Usage: $0 [-h|-v|-d] [--local <build_type>]"
  echo "--local build_type : type de construction de l'image."
  echo " - docker"
  echo "      construit une image docker pour Jenkins, basé sur AmazonLinux 2023"
  echo " - vagrant"
  echo "      construit une image vagrant pour Jenkins, basé sur AmazonLinux 2023"
  echo " - amazon-ebs (par defaut si valeur est vide)"
  echo "      construit une AMI sur AWS"
  echo ""
  echo "options:"
  echo "-h     Affiche cette aide."
  echo "-v     Affiche packer en mode TRACE."
  echo "-d     Utilise le mode debug (pas à pas)."
  echo
}

# Check for required tools
declare -a req_tools=( "packer" "hcl2json" "sed" "curl" "jq" "vagrant" )
for tool in "${req_tools[@]}"; do
  if ! command -v "$tool" > /dev/null; then
    fail "It looks like '${tool}' is not installed; please install it and run this setup script again."
  fi
done

# Paths Variables
PACKER_ROOT_DIR="$(dirname "$(realpath "$0")")"
PACKER_EXTRA_ARGS="${*}"
PACKER_TEMPLATE_DIR="$PACKER_ROOT_DIR/templates"
PACKER_OUTPUT_FILE="$PACKER_ROOT_DIR/packer.out"
# PACKER_CACHE_DIR="packer_cache"
PACKER_BUILD="amazon-ebs.source"
PACKER_CMD_LINE=""

# shellcheck disable=SC2034
CHECKPOINT_DISABLE=1
# shellcheck disable=SC2034
VAGRANT_CHECKPOINT_DISABLE=1
# Vagrant variables
VAGRANT_HOME="$HOME/.vagrant.d"
VAGRANT_SSH_PRIVATE_KEY="$VAGRANT_HOME/insecure_private_key"
VAGRANT_BOX_HOME="$VAGRANT_HOME/boxes"
VAGRANT_BOX_DOWNLOAD="$VAGRANT_HOME/downloaded"

# vagrant check
PACKER_VARS_FILE="$(pwd)/packer.auto.pkrvars.hcl"
PACKER_TEMPLATE="$(hcl2json < "$PACKER_VARS_FILE" | jq -r -c .template)"
PACKER_TEMPLATE_PATH="${PACKER_TEMPLATE_DIR}/${PACKER_TEMPLATE}"

if [ ! -d "${PACKER_TEMPLATE_PATH}" ] ; then
  fail "Incorrect folder for packer templates : ${PACKER_TEMPLATE_PATH}"
fi

# Parse remaining options
while getopts ":hvdlocal" option; do
  case $option in
      h) # display Help
        _help
        exit;;
      v) # packer verbose mode
        export PACKER_LOG=1
        echo "==> PACKER_LOG=1"
        ;;
      d) # packer debug mode
        PACKER_EXTRA_ARGS="-debug"
        msg "==> PACKER_DEBUG=" "true"
        ;;
      l) # local build
        PACKER_BUILD_TYPE="local"
        ;;
      *)
        continue
        ;;
  esac
done

# Remove the options from the arguments
shift $((OPTIND - 1))

# Build local
if [ "$PACKER_BUILD_TYPE" = "local" ]; then

  PROVIDER="$1"
  if [ -z "${PROVIDER}" ] ; then
    fail "Incorrect provider defined: can be docker/qemu/virtualbox"
  fi

  case "$PROVIDER" in
    docker)
      PACKER_BUILD="docker.source"
      msg "==> Starting build template" "${PACKER_BUILD}"
      PACKER_EXTRA_ARGS="-only=${PROVIDER}"
      ;;
    qemu|virtualbox|libvirt)
      PACKER_BUILD="$PROVIDER.source"
      msg "==> Starting build template" "${PACKER_BUILD}"

      BOX_NAME="$(hcl2json < "${PACKER_TEMPLATE_PATH}/variables.pkr.hcl" | jq -r -c .variable.box_name[].default)"
      BOX_OS="${BOX_NAME%%/*}"
      BOX_DISTRIB="${BOX_NAME##*/}"

      msg "==> BOX_OS" "${BOX_OS}"
      msg "==> BOX_NAME" "${BOX_NAME}"
      msg "==> BOX_DISTRIB" "${BOX_DISTRIB}"

      # Get some metadata box from cloud repositories
      # To find/fix somes URL boxes : try https://portal.cloud.hashicorp.com/vagrant/discover
      case ${BOX_OS} in
        debian)
          METADATA=$(curl -s https://salsa.debian.org/cloud-team/vagrant-boxes/raw/master/packer-virtualbox-vagrant/virtualbox-"${BOX_DISTRIB%%64}".SHA256SUM)
          BOX_CHECKSUM=$(echo "$METADATA" | cut -d' ' -f1)
          BOX_VERSION=$(echo "$METADATA" | cut -d' ' -f3)
          BOX_FILENAME=$(echo "$METADATA" | cut -d' ' -f2)
          BOX_URL="https://app.vagrantup.com/${BOX_OS}/boxes/${BOX_DISTRIB}/versions/${BOX_VERSION}/providers/virtualbox.box"
        ;;
        bento | generic | roboxes)
          BOX_VERSION="$(hcl2json < "${PACKER_TEMPLATE_PATH}/variables.pkr.hcl" | jq -r -c .variable.box_version[].default)"
          BOX_FILENAME="$PROVIDER.box"
          ## TODO : get architecture from metadata
          BOX_URL="https://vagrantcloud.com/${BOX_OS}/boxes/${BOX_DISTRIB}/versions/${BOX_VERSION}/providers/${PROVIDER}/amd64/download/vagrant.box"
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

      msg "==> BOX_VERSION" "${BOX_VERSION}"
      msg "==> BOX_URL" "${BOX_URL}"
      msg "==> BOX_FULLPATH" "${BOX_FULLPATH}"

      # Create box folder if it doesn't exist
      [ ! -d "$BOX_FULLPATH_FOLDER" ] && mkdir -p "$BOX_FULLPATH_FOLDER"
      cd "$BOX_FULLPATH_FOLDER"

      # Check if box already exist
      if [ ! -f "$BOX_FULLPATH" ]; then
        curl -sL "$BOX_URL" -o "$BOX_FILENAME"
      else
        # box already exist
        warm "Box already exist: $BOX_FULLPATH"
        read -r -p "Replace existing box ? [y/N] : "
        case $REPLY in
          [yY])
            info "we REPLACE the existing box."
            curl -sL "$BOX_URL" -o "$BOX_FILENAME"
            ;;
          *)
            info "we KEEP the existing box."
          ;;
        esac
      fi

      # Get checksum from file box if it don't exist yet
      [ -z "$BOX_CHECKSUM" ] && BOX_CHECKSUM=$(sha256sum "$BOX_FULLPATH" | cut -d' ' -f1)

      # add box into vagrant
      cd - &>/dev/null && \
      vagrant box add \
        --force \
        --name "$BOX_NAME" \
        --checksum "$BOX_CHECKSUM" \
        --checksum-type "sha256" \
        "$BOX_FULLPATH"

      if [ "$PROVIDER" = "virtualbox" ]; then
          VAGRANT_BOX_FOLDER="$(realpath "$VAGRANT_BOX_HOME/$BOX_OS-VAGRANTSLASH-$BOX_DISTRIB/0/$PROVIDER")"
          VAGRANT_BOX_FOLDER="$(realpath "$VAGRANT_BOX_HOME/$BOX_OS-VAGRANTSLASH-$BOX_DISTRIB/0/virtualbox")"
          OVF_CHECKSUM="$(sha256sum "$VAGRANT_BOX_FOLDER"/box.ovf | awk '{ print $1}')"
          BOX_BASE_MAC="$(sed -n 's/.*base_mac = "\(.*\)"/\1/p' "$VAGRANT_BOX_FOLDER"/Vagrantfile)"
          PACKER_CMD_LINE="-only=virtualbox-ovf.source -var box_folder=${VAGRANT_BOX_FOLDER} -var box_base_mac=${BOX_BASE_MAC} -var box_checksum=${OVF_CHECKSUM} -var vagrant_ssh_private_key=${VAGRANT_SSH_PRIVATE_KEY}"

          msg "==> VAGRANT_BOX_FOLDER" "${VAGRANT_BOX_FOLDER}"
          msg "==> BOX_BASE_MAC" "${BOX_BASE_MAC}"
          msg "==> OVF_CHECKSUM" "${OVF_CHECKSUM}"
        else
          VAGRANT_BOX_FOLDER="$(realpath "$VAGRANT_BOX_HOME/$BOX_OS-VAGRANTSLASH-$BOX_DISTRIB/0/libvirt")"
          IMG_CHECKSUM="$(sha256sum "$VAGRANT_BOX_FOLDER"/box.img | awk '{ print $1}')"
          PACKER_CMD_LINE="-only=qemu.source -var box_folder=${VAGRANT_BOX_FOLDER} -var box_checksum=${IMG_CHECKSUM} -var vagrant_ssh_private_key=${VAGRANT_SSH_PRIVATE_KEY}"

          msg "==> VAGRANT_BOX_FOLDER" "${VAGRANT_BOX_FOLDER}"
          msg "==> IMG_CHECKSUM" "${IMG_CHECKSUM}"
      fi

      # Display vagrant box information
      msg "==> SSH command:" "ssh -i ~/.vagrant.d/insecure_private_key -p 62222 vagrant@localhost"
      msg "==> VAGRANT_SSH_PRIVATE_KEY" "${VAGRANT_SSH_PRIVATE_KEY}"

      msg "==> BOX_FILENAME" "${BOX_FILENAME}"
      msg "==> BOX_CHECKSUM" "${BOX_CHECKSUM}"
      msg "==> PROVIDER" "${PROVIDER}"
      ;;
    *)
      fail "Incorrect provider defined: can be docker/qemu/virtualbox"
      ;;
  esac

fi

# Check if extra args is empty
if [ -z "${PACKER_EXTRA_ARGS}" ]; then
  PACKER_EXTRA_ARGS="--"
fi

if [ -n "${PACKER_CMD_LINE}" ]; then
  PACKER_EXTRA_ARGS="${PACKER_CMD_LINE} ${PACKER_EXTRA_ARGS} --"
else
  PACKER_EXTRA_ARGS="-only=amazon-ebs.source ${PACKER_EXTRA_ARGS} --"
fi

msg "==> PACKER_VARS_FILE=" "${PACKER_VARS_FILE}"
msg "==> PACKER_TEMPLATE=" "${PACKER_TEMPLATE}"
msg "==> PACKER_TEMPLATE_PATH=" "${PACKER_TEMPLATE_PATH}"

# build image with packer
msg "==> PACKER_BUILD" "${PACKER_BUILD}"
msg "==> PACKER_OUTPUT_FILE" "${PACKER_OUTPUT_FILE}"
msg "==> PACKER_EXTRA_ARGS" "${PACKER_EXTRA_ARGS}"

# Initialise packer template
packer init "${PACKER_TEMPLATE_PATH}"

# PACKER_CMD_LINE="packer build -force \
#   -var-file="$PACKER_VARS_FILE" \
#   -var "box_folder=${VAGRANT_BOX_FOLDER}" \
#   -var "box_base_mac=${BOX_BASE_MAC}" \
#   -var "box_checksum=${OVF_CHECKSUM}" \
#   -var "vagrant_ssh_private_key=${VAGRANT_SSH_PRIVATE_KEY}" \
#   ${PACKER_EXTRA_ARGS} \
#   ${PACKER_TEMPLATE_PATH} | tee -i ${PACKER_OUTPUT_FILE}"

# -var "box_folder=${VAGRANT_BOX_FOLDER}" \
# -var "box_base_mac=${BOX_BASE_MAC}" \
# -var "box_checksum=${OVF_CHECKSUM}" \
# -var "vagrant_ssh_private_key=${VAGRANT_SSH_PRIVATE_KEY}" \

# echo "packer build -force -var-file=$PACKER_VARS_FILE ${PACKER_EXTRA_ARGS} ${PACKER_TEMPLATE_PATH}"
#  | tee -i "${PACKER_OUTPUT_FILE}"

if packer validate -var-file "$PACKER_VARS_FILE" ${PACKER_TEMPLATE_PATH} ; then
  # shellcheck disable=SC2086
  # echo "packer build -force -var-file=${PACKER_VARS_FILE} ${PACKER_EXTRA_ARGS} ${PACKER_TEMPLATE_PATH} | tee -i ${PACKER_OUTPUT_FILE}"
  packer build -force -var-file=${PACKER_VARS_FILE} ${PACKER_EXTRA_ARGS} ${PACKER_TEMPLATE_PATH} | tee -i "${PACKER_OUTPUT_FILE}"
fi
