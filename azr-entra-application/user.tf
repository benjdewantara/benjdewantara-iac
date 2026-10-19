data "azuread_user" "this" {
  object_id = var.azuread_user_object_id
}

output "a5" {
  value = data.azuread_user.this
}
