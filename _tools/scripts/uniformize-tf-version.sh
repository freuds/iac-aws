#!/usr/bin/env bash
set -euo pipefail
set +x

info() {
  printf "\r\033[00;35m%s\033[0m\n" "$1"
}

fail() {
  printf "\r\033[0;31m%s\033[0m\n" "$1"
}

success() {
  printf "\r\033[00;32m%s\033[0m\n" "$1"
}

WORKING_DIRECTORY="$(dirname "$(realpath "$0")")"
CURRENT_DIRECTORY="$(pwd -P)"

if [[ "${CURRENT_DIRECTORY}" == "${WORKING_DIRECTORY}" ]] ; then
    fail "This script must be launch on the root of repository"
fi

# Version reference
VERSION_REF=$(cat "${CURRENT_DIRECTORY}"/.terraform-version)

# Find all .terraform-version files
find . -type f -name ".terraform-version" -print0 | while read -d $'\0' VERSION_TF
do

  OLDIFS=$IFS
  IFS='/' array=($VERSION_TF)
  IFS=$OLDIFS

  nb=${#array[@]}

  if [[ "$nb" -gt 2 ]] ; then
    current_version=$(cat "${VERSION_TF}")
    echo "Found : version ${current_version} in ${VERSION_TF}"

    # check if .terraform-version is existing and correct
    if [[ ${current_version} != ${VERSION_REF} ]] ; then
        info "Need to change this file ^^^"
        echo $VERSION_REF > $VERSION_TF
        chmod 0644 $VERSION_TF
    fi
  fi

done

# Commit all changes
# echo "Commit all changes ?"
# pause_for_confirmation
# git commit -v -a -s --no-edit --amend

exit 0
