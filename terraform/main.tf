variable "realm_name" {
  type        = string
  description = "Name of the realm to create"
  default     = "demo"
}

variable "keycloack_user" {
  type        = string
  description = "Keycloak admin user"
  default     = "admin"
}

variable "keycloack_password" {
  type        = string
  description = "Keycloak admin password"
  default     = "admin"
}

variable "keycloak_url" {
  type        = string
  description = "Keycloak url"
  default     = "http://localhost:63500"
}

variable "oauth_fqdn" {
  type        = string
  description = "FQDN of the oauth server used for valid redirects"
  default     = "http://localhost:63500/*"
}

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.0.0"
    }
  }
}



# configure keycloak provider
provider "keycloak" {
  client_id                = "admin-cli"
  username                 = "admin"
  password                 = "admin"
  url                      = "http://localhost:63500/auth"
  tls_insecure_skip_verify = true
}

data "keycloak_realm" "realm" {
  realm = var.realm_name
}

resource "keycloak_openid_client" "client" {
  realm_id  = data.keycloak_realm.realm.id
  client_id = "my-client"

  name    = "my-client"
  enabled = true

  access_type = "CONFIDENTIAL"
  valid_redirect_uris = [
    var.oauth_fqdn
  ]

  login_theme           = "keycloak"
  standard_flow_enabled = true
}


output "keycloak_client_id" {
  value = keycloak_openid_client.client.client_id
}

output "keycloak_client_secret" {
  value     = keycloak_openid_client.client.client_secret
  sensitive = true
}

// creating custom scope
resource "keycloak_openid_client_scope" "this" {
  realm_id               = data.keycloak_realm.realm.id
  name                   = "group_and_roles"
  description            = "When requested, this scope will map a user's group memberships and all roles to a claim"
  include_in_token_scope = true
}

// creating custom group mapper
resource "keycloak_generic_protocol_mapper" "groups" {
  realm_id        = data.keycloak_realm.realm.id
  client_scope_id = keycloak_openid_client_scope.this.id
  name            = "groups mapper"
  protocol        = "openid-connect"
  protocol_mapper = "oidc-group-membership-mapper"
  config = {
    "full.path" : "true",
    "id.token.claim" : "true",
    "access.token.claim" : "true",
    "claim.name" : "groups",
    "userinfo.token.claim" : "true"
  }
}

// creating custom role mapper for realm level roles
resource "keycloak_generic_protocol_mapper" "realm_roles" {
  realm_id        = data.keycloak_realm.realm.id
  client_scope_id = keycloak_openid_client_scope.this.id
  name            = "realm roles mapper"
  protocol        = "openid-connect"
  protocol_mapper = "oidc-usermodel-realm-role-mapper"
  config = {
    "multivalued" : "true",
    "userinfo.token.claim" : "true",
    "id.token.claim" : "true",
    "access.token.claim" : "true",
    "claim.name" : "realm_roles",
    "jsonType.label" : "String"
  }
}

// creating custom role mapper for client level roles
resource "keycloak_generic_protocol_mapper" "client_roles" {
  realm_id        = data.keycloak_realm.realm.id
  client_scope_id = keycloak_openid_client_scope.this.id
  name            = "client roles mapper"
  protocol        = "openid-connect"
  protocol_mapper = "oidc-usermodel-client-role-mapper"
  config = {
    "multivalued" : "true",
    "userinfo.token.claim" : "true",
    "id.token.claim" : "true",
    "access.token.claim" : "true",
    "claim.name" : "client_roles",
    "jsonType.label" : "String"
  }
}

// adding custom scope to client as optional
resource "keycloak_openid_client_optional_scopes" "client_optional_scopes" {
  realm_id  = data.keycloak_realm.realm.id
  client_id = keycloak_openid_client.client.id

  optional_scopes = [
    "address",
    "phone",
    "offline_access",
    "microprofile-jwt",
    keycloak_openid_client_scope.this.name
  ]
}
