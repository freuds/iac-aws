# Terraform Cloud configuration

At fist, you need to login on Terraform Cloud: __terraform login__ to retrieve a fresh token.

Setup as your need the file : __./organization.json__ at the root of project.
it contains the organization's name of TFC, the mail's owner, and define all the different environments.

## Initialisation

Launch the TFC init task:

```shell
task tfc-init
```

This script (_tools/scripts/tfc-manage.py) create an organization based on informations defined in __./organizations.json__ file.
It also update all needed: __\_backend.tf__ to match the organization field.
Also, create one workspace by service (and per region if exist).

## Configuration of environments variables

You must define 2 variables for the project:

- __AWS_ACCESS_KEY_ID__
- __AWS_SECRET_ACCESS_KEY__

Both are type: env variables and are sensitives.
