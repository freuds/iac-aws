#!/usr/bin/env bash
set -euo pipefail
set +x

info() {
  printf "\r\033[00;35m%s\033[0m\n" "$1"
}

msg() {
  printf "\r\033[00;34m%s\033[0m\n" "$1"
}

fail() {
  printf "\r\033[0;31m%s\033[0m\n" "$1"
}

success() {
  printf "\r\033[00;32m%s\033[0m\n" "$1"
}

WORKING_DIRECTORY="$(dirname "$(realpath "$0")")"
CURRENT_DIRECTORY="$(pwd -P)"

if [ "${CURRENT_DIRECTORY}" = "${WORKING_DIRECTORY}" ] ; then
    fail "This script must be launch on the root of repository"
fi

# test args : -fix or -show
FIX=0
ACTION=${1}
if [ ! -z "${ACTION}" ]  && [ "${ACTION}" = "-fix" ]; then
  FIX=1
fi

# Version reference
VERSION_REF=$(cat "${CURRENT_DIRECTORY}"/.terraform-version)
info "Version reference : ${VERSION_REF}"

# Find all .terraform-version files
# Exclude root .terraform-version file from search (mindepth)
find . -type f -name ".terraform-version" -mindepth 2 -print0 | while read -d $'\0' TF_VERSION_FILE
do

  OLDIFS=$IFS
  IFS='/' array=($TF_VERSION_FILE)
  IFS=$OLDIFS
  MODULE_CUR=${array[1]}

  VERSION_CUR=$(cat "${TF_VERSION_FILE}")
  msg "Found : version ${VERSION_CUR} in service ${MODULE_CUR}"

  # check if .terraform-version is existing and correct
  if [ "${VERSION_CUR}" != "${VERSION_REF}" ] && [ "${FIX}" = 1 ] ; then
      info "Need to change this file ^^^"
      echo $VERSION_REF > $VERSION_TF
      chmod 0644 $VERSION_TF
  fi

done

# Commit all changes
# echo "Commit all changes ?"
# pause_for_confirmation
# git commit -v -a -s --no-edit --amend

exit 0
