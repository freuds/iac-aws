#! /bin/bash
set -euo pipefail

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

divider() {
  printf "\r\033[0;1m========================================================================\033[0m\n"
}

pause_for_confirmation() {
  read -rsp $'Press any key to continue (ctrl-c to quit):\n' -n1 key
}

# Set up an interrupt handler so we can exit gracefully
interrupt_count=0
interrupt_handler() {
  ((interrupt_count += 1))

  echo ""
  if [[ $interrupt_count -eq 1 ]]; then
    fail "Really quit? Hit ctrl-c again to confirm."
  else
    echo "Goodbye!"
    exit
  fi
}
trap interrupt_handler SIGINT SIGTERM

# This setup script does all the magic.

# Check for required tools
declare -a req_tools=("terraform" "sed" "curl" "jq")
for tool in "${req_tools[@]}"; do
  if ! command -v "$tool" > /dev/null; then
    fail "It looks like '${tool}' is not installed; please install it and run this setup script again."
    exit 1
  fi
done

# Check for required Terraform version
if ! terraform version -json | jq -r '.terraform_version' &> /dev/null; then
  echo
  fail "Terraform 0.13 or later is required for this setup script!"
  echo "You are currently running:"
  terraform version
  exit 1
fi

# Set up some variables we'll need
HOST="${1:-app.terraform.io}"
TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
# Get owner email and organization_name from json
ORGANIZATION_NAME=$(jq -r '.organization_name' organization.json)
ADMIN_OWNER=$(jq -r '.admin_email' organization.json)

# create organization
create_organization() {
  local result=0
  local response
  response=$(curl https://$HOST/api/v2/organizations \
    --request POST \
    --silent \
    --header "Content-Type: application/vnd.api+json" \
    --header "Authorization: Bearer $TOKEN" \
    --data @- << REQUEST_BODY
{
    "data": {
      "type": "organizations",
      "attributes": {
        "name": "${ORGANIZATION_NAME}",
        "email": "${ADMIN_OWNER}"
      }
    }
}
REQUEST_BODY
)

  if [[ $(echo $response | jq -r '.errors') != null ]]; then
    if [[ $(echo $response | jq -r '.errors[].status') == 422 ]]; then
      info "$(echo $response | jq --raw-output .'errors[].detail')"
    else
      fail "An unknown error occurred: ${response}"
    fi
  elif [[ $(echo $response | jq -r '.data.type') == "organizations" ]]; then
    success "Organization $(echo $response | jq -r '.data.attributes.name') created !!"
  fi
}

# Check if workspace exists already
create_workspace() {
  local result
  local response
  local workdir
  response=$(curl https://$HOST/api/v2/organizations/${ORGANIZATION_NAME}/workspaces \
    --request POST \
    --silent \
    --header "Content-Type: application/vnd.api+json" \
    --header "Authorization: Bearer $TOKEN" \
    --data @- << REQUEST_BODY
{
    "data": {
      "type": "workspaces",
      "attributes": {
        "name": "${WORKSPACE_NAME}",
        "terraform-version": "${TERRAFORM_VERSION}",
        "working-directory": "${WORKING_DIRECTORY}",
        "description": "Workpace ${_ENV} for ${_SERVICE} on ${_REGION}"
      }
    }
}
REQUEST_BODY
)
  if [[ $(echo $response | jq -r '.errors') != null ]]; then
    if [[ $(echo $response | jq -r '.errors[].status') == 422 ]]; then
      info "$(echo $response | jq --raw-output .'errors[].detail')"
    else
      fail "An unknown error occurred: ${response}"
    fi
  elif [[ $(echo $response | jq -r '.data.type') == "workspaces" ]]; then
    success "Workspace $(echo $response | jq -r '.data.attributes.name') created !"
  fi
}

###############################################################################
# Check that we've already authenticated via Terraform in the static credentials
# file.
CREDENTIALS_FILE="$HOME/.terraform.d/credentials.tfrc.json"
TOKEN=$(jq -j --arg h "$HOST" '.credentials[$h].token' $CREDENTIALS_FILE)
if [[ ! -f $CREDENTIALS_FILE || $TOKEN == null ]]; then
  fail "We couldn't find a token in the Terraform credentials file at $CREDENTIALS_FILE."
  fail "Please run 'terraform login', then run this setup script again."
  exit 1
fi

# Create a Terraform Cloud organization
clear
divider
echo "Creating an organization if needed ..."
create_organization
divider
echo

# update organizations name for each _backend.tf file
find . -type f -name "backend.tf" -print0 | while read -d $'\0' BACKEND_TF
do
  echo "Found terraform backend file : ${BACKEND_TF}"
  if ! grep "organization = \"${ORGANIZATION_NAME}\"" $BACKEND_TF 2>&1 >/dev/null ; then
    info "Need to change this file ^^^"
    TEMP=$(mktemp)
    cat $BACKEND_TF |
      sed -e "s/.* organization = \".*\"/    organization = \"${ORGANIZATION_NAME}\"/" \
        > $TEMP
    mv $TEMP $BACKEND_TF
    chmod 0644 $BACKEND_TF
    terraform fmt $BACKEND_TF
  fi
done

divider
echo

# Workspaces creation
# Based on each .terraform-config file present in service/env/region directories
find . -type f -name ".terraform-config" -print0 | while read -d $'\0' CONFIG_TF
do
  echo "Found terraform config file : ${CONFIG_TF}"

  OLDIFS=$IFS
  IFS='/' array=($CONFIG_TF)
  IFS=$OLDIFS

  _SERVICE="${array[1]}"
  _ENV="${array[2]}"
  _REGION="${array[3]}"

  WORKSPACE_NAME="${_SERVICE}-${_ENV}-${_REGION}"
  WORKING_DIRECTORY="${_SERVICE}/${_ENV}/${_REGION}"

  # check if .terraform-config is existing and correct
  if ! grep "name = \"${WORKSPACE_NAME}\"" $CONFIG_TF 2>&1 >/dev/null ; then
    info "Need to change this file ^^^"
    TEMP=$(mktemp)
    cat $CONFIG_TF |
      sed -e "s/.*name = \".*\"/    name = \"${WORKSPACE_NAME}\"/" \
        > $TEMP
    mv $TEMP $CONFIG_TF
    chmod 0644 $CONFIG_TF
  fi

  echo "If needed we create workspace : ${WORKSPACE_NAME} ..."
  create_workspace ${WORKSPACE_NAME} ${WORKING_DIRECTORY}
  echo

done

# Commit all changes
echo "Commit all changes ?"
pause_for_confirmation
git commit -v -a --no-edit --amend

exit 0