provider "azuread" {
  tenant_id = var.tenant_id
}

data "azuread_client_config" "current" {}

data "azuread_user" "this" {
  object_id = var.object_id
}

output "a11" {
  value = data.azuread_user.this
}