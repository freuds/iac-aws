# AWS Auth0 SSO TF Module

## To use the module, you need to install Auth0 terraform provider binary in ~/.terraform/plugins

```sh
cd ~/.terraform.d/plugins && \
wget https://github.com/alexkappa/terraform-provider-auth0/releases/download/v0.1.18/terraform-provider-auth0_v0.1.18_darwin_amd64.tar.gz && \
tar -xzvf terraform-provider-auth0_v0.1.18_darwin_amd64.tar.gz && \
rm -f terraform-provider-auth0_v0.1.18_darwin_amd64.tar.gz
```