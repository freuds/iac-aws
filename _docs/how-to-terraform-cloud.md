# IAC

## Setup organization and workspaces Terraform Cloud
```
#> make init-tf
```

This script (_tools/scripts/tfcloud.sh) create an organization , based on informations defined inside __./organizations.json__ file.
It update all needed _backend.tf to match the organization field.
Also, create all workspaces defined by each

# Setup ENVIRONMENT in Terraform Cloud

for each workspaces, you must set these 2 variables :

**AWS_ACCESS_KEY_ID**
**AWS_SECRET_ACCESS_KEY**

don't forget to enable checkbox for sensitive data option