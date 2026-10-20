data "azuread_user" "this" {
  object_id = var.azuread_user_object_id
}

output "a5" {
  value = data.azuread_user.this
}

output "a9" {
  value = azuread_service_principal.this6.app_role_ids
}

resource "azuread_app_role_assignment" "this" {
  app_role_id         = "00000000-0000-0000-0000-000000000000"
  resource_object_id  = azuread_service_principal.this6.object_id
  principal_object_id = data.azuread_user.this.object_id
}