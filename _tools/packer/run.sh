#!/usr/bin/env bash

set -e -o pipefail
# set -x

# declare colors
CYAN="\e[36m"
# Reset all colors
RESET="\e[0m"

msg() {
  printf "\r%s=${CYAN}%s${RESET}\n" "$1" "$2"
}

_help()
{
  # Display Help
  echo "Construction d'une image automatisée via Packer."
  echo ""
  echo "Usage: $0 [-h|-v|-d] [-s <build_type>]"
  echo "> build_type : type de source pour la construction de l'image."
  echo " - docker"
  echo "      construit une image local sur docker"
  echo " - vagrant"
  echo "      construit une image local via vagrant et virtualbox"
  echo " - aws (par defaut si valeur est vide)"
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
    echo "❌ It looks like '${tool}' is not installed; please install it and run this setup script again."
    exit 1
  fi
done

# Paths Variables
PACKER_BUILD_SOURCE="${PACKER_BUILD_SOURCE:=docker}"
PACKER_EXTRA_ARGS="--"

PACKER_ROOT_DIR="$(dirname "$(realpath "$0")")"
PACKER_OUTPUT_FILE="$PACKER_ROOT_DIR/packer.out"
#
PACKER_VARS_FILE="$(pwd)/packer.auto.pkrvars.hcl"
OS_FAMILY="$(hcl2json < "$PACKER_VARS_FILE" | jq -r -c .os_family)"
OS_NAME="$(hcl2json < "$PACKER_VARS_FILE" | jq -r -c .os_name)"
OS_VERSION="$(hcl2json < "$PACKER_VARS_FILE" | jq -r -c .os_version | sed 's/\.//g')"
PACKER_TEMPLATE_PATH="${PACKER_ROOT_DIR}/${OS_FAMILY}/${OS_NAME}"

if [ ! -d "${PACKER_TEMPLATE_PATH}" ] ; then
  echo "❌ Incorrect folder for packer templates : ${PACKER_TEMPLATE_PATH}"
  exit 1
fi

# Parse remaining options
while getopts ":hvds:" option; do
  case $option in
      h) # display Help
        _help
        exit
        ;;
      v) # packer verbose mode
        export PACKER_LOG=1
        msg "==> PACKER_LOG=" "${PACKER_OUTPUT_FILE}"
        ;;
      d) # packer debug mode
        PACKER_EXTRA_ARGS="-debug"
        msg "==> PACKER_DEBUG=" "true"
        ;;
      s)
        case "${OPTARG}" in
          docker|vagrant)
            PACKER_BUILD_SOURCE="${OPTARG}"
            ;;
          aws|amazon)
            PACKER_BUILD_SOURCE="amazon-ebs"
            ;;
          *)
            echo "❌ Erreur : valeur invalide pour -s. Attendu : docker, vagrant ou aws." >&2
            exit 1
            ;;
        esac
        ;;
      \?)
        echo "❌ Option invalide: -$OPTARG" >&2
        _help
        exit 1
        ;;
      :)
        echo "❌ L'option -$OPTARG nécessite un argument." >&2
        _help
        exit 1
        ;;
  esac
done

# Construct the packer build name
PACKER_BUILD="${PACKER_BUILD_SOURCE}.${OS_NAME}-${OS_VERSION}"

msg "==> PACKER_BUILD=" "${PACKER_BUILD}"
msg "==> PACKER_VARS_FILE=" "${PACKER_VARS_FILE}"
msg "==> OS_BASE=" "${OS_FAMILY}/${OS_NAME}:${OS_VERSION}"

# packer init -upgrade "${PACKER_ROOT_DIR}/all"

packer validate \
  -var-file="${PACKER_VARS_FILE}" \
  -only="${PACKER_BUILD}" \
  "${PACKER_ROOT_DIR}/all"

packer build -force \
  -var-file="${PACKER_VARS_FILE}" \
  -only="${PACKER_BUILD_SOURCE}.${OS_NAME}-${OS_VERSION}" \
  "${PACKER_EXTRA_ARGS}" \
  "${PACKER_ROOT_DIR}/all" | tee -i "${PACKER_OUTPUT_FILE}"
