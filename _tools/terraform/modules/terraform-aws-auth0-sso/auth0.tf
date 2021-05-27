resource "auth0_client" "auth0-cli" {
  name        = "${aws_iam_account_alias.current.account_alias}-aws-cli-sso"
  description = "CLI for obtaining JWT and SAML access tokens to ${aws_iam_account_alias.current.account_alias} AWS account"
  app_type    = "spa"

  grant_types = [
    "authorization_code",
    "implicit",
    "refresh_token",
  ]

  is_token_endpoint_ip_header_trusted = false
  is_first_party                      = true
  oidc_conformant                     = true
  sso_disabled                        = false
  cross_origin_auth                   = false
  logo_uri                            = ""
  sso                                 = true

  callbacks = [
    "http://localhost:12200/saml",
    "http://localhost:12200/callback",
    "https://signin.aws.amazon.com/saml",
  ]

  addons {
    samlp {
      audience                      = "https://signin.aws.amazon.com/saml"
      authn_context_class_ref       = ""
      binding                       = ""
      create_upn_claim              = false
      destination                   = ""
      digest_algorithm              = "sha1"
      include_attribute_name_format = true
      lifetime_in_seconds           = var.lifetime_in_seconds
      logout                        = {}
      map_unknown_claims_as_is      = false
      map_identities                = false
      mappings = {
        email = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
        name  = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
      }
      name_identifier_format = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
      name_identifier_probes = [
        "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress",
      ]
      passthrough_claims_with_no_mapping = false
      recipient                          = "https://signin.aws.amazon.com/saml"
      sign_response                      = false
      signature_algorithm                = "rsa-sha1"
      typed_attributes                   = true
    }
  }

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = var.lifetime_in_seconds
    secret_encoded      = false
  }

  custom_login_page_on = true
}

resource "auth0_client" "auth0-console" {
  name        = "${aws_iam_account_alias.current.account_alias}-aws-console-sso"
  description = "CLI for obtaining JWT and SAML access tokens to ${aws_iam_account_alias.current.account_alias} AWS account"
  app_type    = "spa"

  grant_types = [
    "authorization_code",
    "implicit",
    "refresh_token",
  ]

  is_token_endpoint_ip_header_trusted = false
  is_first_party                      = true
  oidc_conformant                     = true
  sso_disabled                        = false
  cross_origin_auth                   = false
  logo_uri                            = ""
  sso                                 = true

  callbacks = [
    "https://signin.aws.amazon.com/saml"
  ]

  addons {
    samlp {
      audience                      = "https://signin.aws.amazon.com/saml"
      authn_context_class_ref       = ""
      binding                       = ""
      create_upn_claim              = false
      destination                   = ""
      digest_algorithm              = "sha1"
      include_attribute_name_format = true
      lifetime_in_seconds           = var.lifetime_in_seconds
      logout                        = {}
      map_unknown_claims_as_is      = false
      map_identities                = false
      mappings = {
        email = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
        name  = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
      }
      name_identifier_format = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
      name_identifier_probes = [
        "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress",
      ]
      passthrough_claims_with_no_mapping = false
      recipient                          = "https://signin.aws.amazon.com/saml"
      sign_response                      = false
      signature_algorithm                = "rsa-sha1"
      typed_attributes                   = true
    }
  }

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = var.lifetime_in_seconds
    secret_encoded      = false
  }

  custom_login_page_on = true
}

resource "auth0_rule" "grant-admin" {
  name = "grant aws role to users in ${var.env}"

  /* Note, this script grants both roles to everybody. You may want to grant roles
               based on group memberships or role. */
  script  = data.template_file.aws-auth0-rule.rendered
  enabled = true
}

data "local_file" "auth0-saml-metadata" {
  depends_on = [
  null_resource.auth0-saml-metadata]
  filename = ".saml-metadata.xml"
}

resource "null_resource" "auth0-saml-metadata" {
  triggers = {
    uuid = uuid()
  }
  provisioner "local-exec" {
    command = "curl -L -sS --fail -o .saml-metadata.xml https://${var.auth0_domain}/samlp/metadata/${auth0_client.auth0-cli.client_id}"
  }
}

//data "http" "auth0-saml-metadata" {
//  url = "https://${var.auth0_domain}/samlp/metadata/${auth0_client.auth0-cli.client_id}"
//}