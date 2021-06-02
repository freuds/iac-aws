# IAC

## Setup organization and workspaces Terraform Cloud
```
#> make tfinit
```

This script (_tools/scripts/tfcloud.sh) create an organization , defined inside __./organizations.json__ file.
It update all needed _backend.tf to match the organization field.
Also, create all workspaces defined by each 

# Setup ENVIRONMENT in Terraform Cloud

for each workspace, you must set these variables

AWS_ACCESS_KEY_ID 
AWS_SECRET_ACCESS_KEY

Check senstive data option