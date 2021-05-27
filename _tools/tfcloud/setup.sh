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
# PROVIDER_TF=$(dirname ${BASH_SOURCE[0]})/../provider.tf
TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')

# Get owner email and organization_name from json
ORGANIZATION_NAME=$(jq -r '.organization_name' tf-organization.json)
ADMIN_OWNER=$(jq -r '.admin_email' tf-organization.json)

echo "ORGANIZATION_NAME: $ORGANIZATION_NAME"
echo "ADMIN_OWNER: $ADMIN_OWNER"

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
    fail "An unknown error occurred: ${response}"
  elif [[ $(echo $response | jq -r '.data.type') == "organizations" ]]; then
    result=$(echo $response | jq -r '.data.attributes.name')
  fi
  echo $result
}

# Check if organization exists already
check_exist_organization() {
  local result
  local response
  response=$(curl https://$HOST/api/v2/organizations/${ORGANIZATION_NAME} \
    --request GET \
    --silent \
    --header "Content-Type: application/vnd.api+json" \
    --header "Authorization: Bearer $TOKEN")

  if [[ $(echo $response | jq -r '.data.type') == "organizations" ]]; then
    result=$(echo $response | jq -r '.data.attributes.name')
  else
    result=0
  fi
  echo $result
}

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
# echo
# echo "Check if organization already exists ..."
# org_exist=$(check_exist_organization)
# sleep 1
# if [[ $org_exist == 0 ]]; then

#   echo "Creating an organization ..."
#   org_create=$(create_organization)
#   if [[ $org_create != 0 ]]; then
#     success "Ok. $org_create created."
#   fi

# else
#   info "Found existing organization : ${org_exist}"
# fi

# TODO : update organizations name for each _backend.tf file
BACKEND_TF_LIST=$(find . -type f -name "_backend.tf")
for BACKEND_TF in "${BACKEND_TF_LIST[@]}"
do
  if ! grep "organization = \"${ORGANIZATION_NAME}\"" $BACKEND_TF 2>/dev/null ; then
    info "Need to change file: $BACKEND_TF"
    # We don't sed -i because MacOS's sed has problems with it.
    TEMP=$(mktemp)
    cat $BACKEND_TF |
      sed -e "s/.* organization = \".*\"/    organization = \"${ORGANIZATION_NAME}\"/" \
        > $TEMP
    mv $TEMP $BACKEND_TF
    terraform fmt $BACKEND_TF
    git commit -v -a -s --no-edit --amend
  fi
done
# TODO 
# 'gcan!'='git commit -v -a --no-edit --amend'
# 'gcans!'='git commit -v -a -s --no-edit --amend'

# Workspaces creation
# Based on each .terraform-config file present in service/env/region folders





exit 0



echo
echo "Writing remote backend configuration to backend.tf..."
sleep 2

# We don't sed -i because MacOS's sed has problems with it.
TEMP=$(mktemp)
cat $BACKEND_TF |
  # add backend config for the hostname if necessary
  if [[ "$HOST" != "app.terraform.io" ]]; then sed "5a\\
\    hostname = \"$HOST\"
    "; else cat; fi |
  # replace the organization and workspace names
  sed "s/{{ORGANIZATION_NAME}}/${organization_name}/" |
  sed "s/{{WORKSPACE_NAME}}/${workspace_name}/" \
    > $TEMP
mv $TEMP $BACKEND_TF

# add extra provider config for the hostname if necessary
if [[ "$HOST" != "app.terraform.io" ]]; then
  TEMP=$(mktemp)
  cat $PROVIDER_TF |
    sed "11a\\
  \  hostname = var.provider_hostname
      " \
      > $TEMP
  echo "
variable \"provider_hostname\" {
  type = string
}" >> $TEMP
  mv $TEMP $PROVIDER_TF
fi

# echo
# divider
# echo
# success "Ready to go; the example configuration is set up to use Terraform Cloud!"
# echo
# echo "An example workspace named '${workspace_name}' was created for you."
# echo "You can view this workspace in the Terraform Cloud UI here:"
# echo "https://$HOST/app/${organization_name}/workspaces/${workspace_name}"
# echo
# info "Next, we'll run 'terraform init' to initialize the backend and providers:"
# echo
# echo "$ terraform init"
# echo
# pause_for_confirmation

# echo
# terraform init
# echo
# echo "..."
# sleep 2
# echo
# divider
# echo
# info "Now it’s time for 'terraform plan', to see what changes Terraform will perform:"
# echo
# echo "$ terraform plan"
# echo
# pause_for_confirmation

# echo
# terraform plan
# echo
# echo "..."
# sleep 3
# echo
# divider
# echo
# success "The plan is complete!"
# echo
# echo "This plan was initiated from your local machine, but executed within
# Terraform Cloud!"
# echo
# echo "Terraform Cloud runs Terraform on disposable virtual machines in
# its own cloud infrastructure. This 'remote execution' helps provide consistency
# and visibility for critical provisioning operations. It also enables notifications,
# version control integration, and powerful features like Sentinel policy enforcement
# and cost estimation (shown in the output above)."
# echo
# info "To actually make changes, we'll run 'terraform apply'. We'll also auto-approve
# the result, since this is an example:"
# echo
# echo "$ terraform apply -auto-approve"
# echo
# pause_for_confirmation

# echo
# terraform apply -auto-approve

# echo
# echo "..."
# sleep 3
# echo
# divider
# echo
# success "You did it! You just provisioned infrastructure with Terraform Cloud!"
# echo
# info "The organization we created here has a 30-day free trial of the Team &
# Governance tier features. After the trial ends, you'll be moved to the Free tier."
# echo
# echo "You now have:"
# echo
# echo "  * Workspaces for organizing your infrastructure. Terraform Cloud manages"
# echo "    infrastructure collections with workspaces instead of directories. You"
# echo "    can view your workspace here:"
# echo "    https://$HOST/app/$organization_name/workspaces/$workspace_name"
# echo "  * Remote state management, with the ability to share outputs across"
# echo "    workspaces. We've set up state management for you in your current"
# echo "    workspace, and you can reference state from other workspaces using"
# echo "    the 'terraform_remote_state' data source."
# echo "  * Much more!"
# echo
# info "To see the mock infrastructure you just provisioned and continue exploring
# Terraform Cloud, visit:
# https://$HOST/fake-web-services"
# echo
# exit 0
