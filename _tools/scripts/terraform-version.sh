#!/usr/bin/env bash
set -euo pipefail

# Declare Root project directory
ROOT_DIRECTORY="$1"

# shellcheck disable=SC1091
source "${ROOT_DIRECTORY}/_tools/scripts/common.sh"

# Set up an interrupt handler so we can exit gracefully
trap interrupt_handler SIGINT SIGTERM

# Version reference
VERSION_REF=$(cat "${ROOT_DIRECTORY}"/.terraform-version)
info "=> Terraform global version" "${VERSION_REF}"

# Find all .terraform-version files
# Exclude root .terraform-version file from search (mindepth)
cd "${ROOT_DIRECTORY}" || fail "Failed to change directory to ${ROOT_DIRECTORY}"
find . -type f -name ".terraform-version" -mindepth 2 -print0 | while read -r -d $'\0' TF_VERSION_FILE
do
  # Get module name with the 1 part of each string
  MODULE_CUR=$(echo "${TF_VERSION_FILE}" | awk -F'/' '{print $2}')
  # Get current version
  VERSION_CUR=$(cat "${TF_VERSION_FILE}")

  # check if .terraform-version is existing and correct
  if [ -n "${MODULE_CUR}" ] ; then
    if [ "${VERSION_CUR}" != "${VERSION_REF}" ] ; then
      echo -n "${VERSION_REF}" > "${TF_VERSION_FILE}"
      chmod 0644 "${TF_VERSION_FILE}"
      success "${MODULE_CUR}" "${VERSION_REF}"
    else
      msg "${MODULE_CUR}" "${VERSION_CUR}"
    fi
  fi
done

# Commit all changes
# git status
# echo "Commit all changes ?"
# pause_for_confirmation
# #git commit -v -a -s --no-edit --amend
# info "Changes have been made. Consider running 'git commit -am \"Update Terraform versions\"' to save them."

exit 0
