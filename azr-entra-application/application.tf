provider "azuread" {
  tenant_id = "87f7da99-d436-4073-a47d-bbd48f2e8dd8"
}

data "azuread_client_config" "current" {}

output "whoami" {
  value = data.azuread_client_config.current.id
}
