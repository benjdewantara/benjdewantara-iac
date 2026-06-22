provider "azuread" {
  tenant_id = "87f7da99-d436-4073-a47d-bbd48f2e8dd8"
}

data "azuread_client_config" "current" {}

resource "azuread_application_registration" "this" {
  display_name = "Test Entra Application"
}

resource "azuread_application_redirect_uris" "this" {
  application_id = azuread_application_registration.this.id
  redirect_uris = ["http://localhost:8080"]
  type           = "Web"
}

output "whoami" {
  value = data.azuread_client_config.current.id
}
