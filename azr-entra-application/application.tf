provider "azuread" {
  tenant_id = var.tenant_id
}

data "azuread_client_config" "current" {}

resource "azuread_application" "this" {
  display_name            = var.app_display_name
  prevent_duplicate_names = true
}

resource "azuread_service_principal" "this4" {
  client_id                     = azuread_application.this.client_id
  preferred_single_sign_on_mode = "oidc"
  app_role_assignment_required  = false

  # feature_tags {
  #   custom_single_sign_on = true
  #   enterprise            = true
  #   # gallery               = true
  # }
}
