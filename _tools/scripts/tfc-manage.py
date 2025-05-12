#!/usr/bin/env python3
import json
import os
import sys
import logging
import re
import string
from os.path import join  # Import join from os.path for path manipulation
import subprocess  # Import the subprocess module to run shell commands
# import requests  # Import the requests library
import requests; print(requests.get("https://astral.sh"))

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def print_title(text):
    """
    Prints a separator line, the given text, and another separator line.

    Args:
        text: The text to be printed between the separator lines.
    """
    separator = "=" * 79
    print(separator)
    print(text)
    print(separator)

def print_sep():
    """
    Prints a separator line
    """
    separator = "-" * 79
    print(separator)
    print()

def manage_organization(host, token, organization_name, admin_owner):
    """
    Creates a Terraform Cloud organization if it doesn't exist.

    Args:
        host (str): The Terraform Cloud host (e.g., "app.terraform.io").
        token (str): The Terraform Cloud API token.
        organization_name (str): The name of the organization to create.
        admin_owner (str): The email address of the organization administrator.

    Returns:
        bool: True on success, False on failure.
    """
    url = f"https://{host}/api/v2/organizations"
    headers = {
        "Content-Type": "application/vnd.api+json",
        "Authorization": f"Bearer {token}",
    }
    payload = {
        "data": {
            "type": "organizations",
            "attributes": {
                "name": organization_name,
                "email": admin_owner,
            },
        },
    }
    try:
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()  # Raise HTTPError for bad responses (4xx or 5xx)
        response_json = response.json()

        if "data" in response_json and response_json.get("data").get("type") == "organizations":
            org_name = response_json.get("data").get("attributes").get("name")
            logging.info(f"Organization '{org_name}' created successfully!")
            return True
        else:
            logging.error(f"Failed to create organization. Response: {response_json}")
            return False
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 422:
            logging.info(f"Organization \"{organization_name}\" already exists. Nothing to do.")
        else:
            logging.error(f"HTTP error creating workspace: {e}")
            return False
    except requests.exceptions.RequestException as e:
        print(response)
        logging.error(f"Error creating organization: {e}")
        return False

def create_or_update_workspace(host, token, organization_name, workspace_name, terraform_version, working_directory, workspace_description):
    """
    Creates or updates a Terraform Cloud workspace.

    Args:
        host (str): The Terraform Cloud host.
        token (str): The Terraform Cloud API token.
        organization_name (str): The name of the Terraform Cloud organization.
        workspace_name (str): The name of the workspace.
        terraform_version (str): The Terraform version.
        working_directory (str): The working directory for the workspace.
        workspace_description (str): Description of the workspace.

    Returns:
        bool: True on success, False on failure.
    """
    url = f"https://{host}/api/v2/organizations/{organization_name}/workspaces"
    headers = {
        "Content-Type": "application/vnd.api+json",
        "Authorization": f"Bearer {token}",
    }
    payload = {
        "data": {
            "type": "workspaces",
            "attributes": {
                "name": workspace_name,
                "terraform-version": terraform_version,
                "working-directory": working_directory,
                "description": workspace_description,
            },
        },
    }

    try:
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()  # Will raise an HTTPError for bad responses (like 422)
        response_json = response.json()

        if "data" in response_json and response_json.get("data").get("type") == "workspaces":
            created_name = response_json.get("data").get("attributes").get("name")
            logging.info(f"Workspace \"{created_name}\" created successfully!")
            return True
        else:
            logging.error(f"Failed to create workspace. Response: {response_json}")
            return False

    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 422:
            logging.info(f"Workspace \"{workspace_name}\" already exists. Attempting to update.")
            return update_workspace(host, token, organization_name, workspace_name, terraform_version, working_directory, workspace_description)
        else:
            logging.error(f"HTTP error creating workspace: {e}")
            return False
    except requests.exceptions.RequestException as e:
        logging.error(f"Error creating/updating workspace: {e}")
        return False


def update_workspace(host, token, organization_name, workspace_name, terraform_version, working_directory, workspace_description):
    """
    Updates an existing Terraform Cloud workspace.

    Args:
        host (str): The Terraform Cloud host.
        token (str): The Terraform Cloud API token.
        organization_name (str): The name of the Terraform Cloud organization.
        workspace_name (str): The name of the workspace to update.
        terraform_version (str): The Terraform version.
        working_directory (str): The working directory for the workspace.
        workspace_description (str): Description of the workspace.

    Returns:
        bool: True on success, False on failure.
    """
    url = f"https://{host}/api/v2/organizations/{organization_name}/workspaces/{workspace_name}"
    headers = {
        "Content-Type": "application/vnd.api+json",
        "Authorization": f"Bearer {token}",
    }
    payload = {
        "data": {
            "type": "workspaces",
            "attributes": {
                "name": workspace_name,
                "terraform-version": terraform_version,
                "working-directory": working_directory,
                "description": workspace_description,
                "global-remote-state": True,
            },
        },
    }

    try:
        response = requests.patch(url, headers=headers, json=payload)
        response.raise_for_status()
        response_json = response.json()

        if "data" in response_json and response_json.get("data").get("type") == "workspaces":
            updated_name = response_json.get("data").get("attributes").get("name")
            logging.info(f"Workspace \"{updated_name}\" updated successfully!")
            return True
        else:
            logging.error(f"Failed to update workspace. Response: {response_json}")
            return False
    except requests.exceptions.RequestException as e:
        logging.error(f"Error updating workspace: {e}")
        return False



def update_backend_files(organization_name):
    """
    Updates the organization name in all backend.tf files.

    Args:
        organization_name (str): The name of the Terraform Cloud organization.
    """
    try:
        result = subprocess.run(
            ['find', '.', '-type', 'f', '-name', 'backend.tf', '-print0'],
            capture_output=True, text=True, check=True
        )
        backend_files = result.stdout.split('\0')[:-1]  # Split by null, remove last empty string

        for backend_tf in backend_files:
            logging.info(f"Checking Terraform backend file: {backend_tf}")
            with open(backend_tf, 'r') as f:
                content = f.read()

            if f'organization = "{organization_name}"' not in content:
                logging.info(f"Need to update this file: {backend_tf}")
                # Use re.sub to replace the line
                new_content = re.sub(r'(\s*organization\s*=\s*").*(")', f'\\1{organization_name}\\2', content)

                with open(backend_tf, 'w') as f:
                    f.write(new_content)
                subprocess.run(['chmod', '0644', backend_tf], check=True)
                subprocess.run(['terraform', 'fmt', backend_tf], check=True)
    except subprocess.CalledProcessError as e:
        logging.error(f"Error updating backend.tf files: {e}")
        sys.exit(1)
    except Exception as e:
        logging.error(f"An unexpected error occurred: {e}")
        sys.exit(1)



def create_workspaces_from_config(host, token, organization_name):
    """
    Creates Terraform Cloud workspaces based on config.remote.tfbackend files.

    Args:
        host (str): The Terraform Cloud host.
        token (str): The Terraform Cloud API token.
        organization_name (str): The name of the Terraform Cloud organization.
    """
    try:
        result = subprocess.run(
            ['find', '.', '-type', 'f', '-name', 'config.remote.tfbackend', '-print0'],
            capture_output=True, text=True, check=True
        )
        config_files = result.stdout.split('\0')[:-1]

        for config_tf in config_files:
            logging.info(f"Found Terraform config file: {config_tf}")
            parts = config_tf.split('/')
            service = parts[1]
            env = parts[2]
            region = parts[3]

            workspace_name = "-".join([service, env, region])
            working_directory = "/".join([service, env, region])
            workspace_description = f"Workspace : {env.upper()} for {service.upper()} on {region.upper()}"

            # Check if config.remote.tfbackend exists and is correct
            with open(config_tf, 'r') as f:
                content = f.read()
            if f'name = "{workspace_name}"' not in content:
                logging.info(f"Need to change this file: {config_tf}")
                new_content = re.sub(r'(\s*name\s*=\s*").*(")', f'\\1{workspace_name}\\2', content)
                with open(config_tf, 'w') as f:
                    f.write(new_content)
                subprocess.run(['chmod', '0644', config_tf], check=True)

            # Check if the .terraform-version exists and is correct
            version_tf = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(config_tf))), '_terraform', '.terraform-version')
            if not os.path.exists(version_tf):
                logging.error(f"Missing Terraform version file: {version_tf}")
                continue
            with open(version_tf, 'r') as f:
                terraform_version = f.read()
            logging.info(f"Found Terraform version symlink: {version_tf}")

            create_or_update_workspace(host, token, organization_name, workspace_name, terraform_version, working_directory, workspace_description)
            print_sep()

    except subprocess.CalledProcessError as e:
        logging.error(f"Error processing .terraform-config files: {e}")
        sys.exit(1)
    except Exception as e:
        logging.error(f"An unexpected error occurred: {e}")
        sys.exit(1)


def main():
    """
    Main function to run the script.
    """
    # Set up variables
    host = os.environ.get("TERRAFORM_CLOUD_HOST", "app.terraform.io")
    credentials_file = os.path.join(os.path.expanduser("~"), ".terraform.d", "credentials.tfrc.json")

    try:
        with open(credentials_file, 'r') as f:
            credentials = json.load(f)
        token = credentials['credentials'][host]['token']
    except (FileNotFoundError, KeyError, json.JSONDecodeError):
        logging.error(f"We couldn't find a token in the Terraform credentials file at {credentials_file}.")
        logging.error("Please run 'terraform login', then run this setup script again.")
        sys.exit(1)

    try:
        with open('organization.json', 'r') as f:
            org_data = json.load(f)
        organization_name = org_data['organization_name']
        admin_owner = org_data['admin_email']
    except (FileNotFoundError, KeyError, json.JSONDecodeError):
        logging.error("organization.json must contain 'organization_name' and 'admin_email'.")
        sys.exit(1)

    # Manage organization name
    print_title("Creating an organization if needed ...")
    manage_organization(host, token, organization_name, admin_owner)
    print_sep()

    # Update backend.tf files
    print_title("Updating backend.tf files ...")
    update_backend_files(organization_name)
    print_sep()

    # Create workspaces
    print_title("Creating or updating workspaces ...")
    create_workspaces_from_config(host, token, organization_name)

    print("Script finished.")


if __name__ == "__main__":
    main()
