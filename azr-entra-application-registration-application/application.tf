resource "azuread_service_principal" "this" {
  client_id = azuread_application_registration.this.client_id
}
