provider "azuread" {
  tenant_id = var.tenant_id
}

data "azuread_client_config" "current" {}

# resource "azuread_application" "this" {
resource "azuread_application_registration" "this" {
  display_name = var.app_display_name
  # prevent_duplicate_names = true
}

resource "azuread_service_principal" "this6" {
  # client_id                     = azuread_application.this.client_id
  client_id                     = azuread_application_registration.this.client_id
  preferred_single_sign_on_mode = "oidc"
  app_role_assignment_required  = false

  feature_tags {
    custom_single_sign_on = true
    enterprise            = true
    # gallery               = true
  }
}

# resource "azuread_application_redirect_uris" "this_Web" {
#   application_id = azuread_application_registration.this.id
#   redirect_uris  = ["http://localhost:1234/wkwk"]
#   type           = "Web"
# }

resource "azuread_application_redirect_uris" "this_SPA" {
  application_id = azuread_application_registration.this.id
  redirect_uris  = ["http://localhost:1234/wkwk2"]
  type           = "SPA"
}

output "azuread_application_registration_client_id" {
  value = azuread_application_registration.this.client_id
}

output "azuread_service_principal_client_id" {
  value = azuread_service_principal.this6.client_id
}
