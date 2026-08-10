provider "azuread" {
  tenant_id = var.tenant_id
}

data "azuread_client_config" "current" {}

data "azuread_user" "user_existing" {
  object_id = var.user_object_id
}

data "azuread_application" "app_existing" {
  client_id = var.app_client_id
}

data "azuread_application_published_app_ids" "well_known" {}

output "a17" {
  value = data.azuread_application_published_app_ids.well_known
}

resource "azuread_service_principal" "app_existing" {
  client_id    = data.azuread_application.app_existing.client_id
  use_existing = true
}

output "azuread_application_app_existing" {
  value = data.azuread_application.app_existing
}

output "azuread_service_principal_app_existing" {
  value = azuread_service_principal.app_existing
}

output "user_existing" {
  value = data.azuread_user.user_existing
}

resource "azuread_app_role_assignment" "this" {
  app_role_id         = azuread_service_principal.app_existing.app_roles[0].id
  principal_object_id = data.azuread_user.user_existing.object_id
  resource_object_id  = azuread_service_principal.app_existing.object_id
}
