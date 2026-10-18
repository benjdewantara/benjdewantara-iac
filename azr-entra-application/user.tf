data "azuread_user" "this" {
  object_id = var.azuread_user_object_id
}

output "a5" {
  value = data.azuread_user.this
}

# data "azuread_application" "app_recently_fetched" {
#   object_id = azuread_application.this.object_id
# }

output "a9" {
  # value = data.azuread_application.app_recently_fetched.app_role_ids
  # value = azuread_application.this.app_role_ids
  value = azuread_service_principal.this.app_role_ids
}

# resource "azuread_service_principal" "this_app" {
#   client_id = azuread_application.this.client_id
# }

resource "azuread_app_role_assignment" "this" {
  # app_role_id         = random_uuid.this.id
  app_role_id         = azuread_service_principal.this.app_role_ids["What.WhatValue"]
  principal_object_id = data.azuread_user.this.object_id
  resource_object_id  = azuread_service_principal.this.object_id
}
