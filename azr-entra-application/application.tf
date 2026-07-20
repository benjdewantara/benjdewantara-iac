provider "azuread" {
  tenant_id = var.tenant_id
}

data "azuread_client_config" "current" {}

resource "azuread_application" "this" {
  display_name = var.app_display_name

  sign_in_audience = "AzureADMyOrg"
  api {
    requested_access_token_version = 2
  }
}

resource "azuread_service_principal" "this" {
  client_id = azuread_application.this.client_id
}

resource "azuread_application_redirect_uris" "this" {
  application_id = azuread_application.this.id
  redirect_uris  = ["http://localhost:8080/callback"]
  type           = "Web"
}

resource "azuread_application_password" "this" {
  application_id = azuread_application.this.id
}

data "template_file" "this" {
  template = file("${path.module}/output.txt.template")

  vars = {
    client_secrets = azuread_application_password.this.value
    client_id      = azuread_application_password.this.id
  }
}

output "whoami" {
  value = data.azuread_client_config.current.id
}

output "client_secrets_id_file_content" {
  value     = data.template_file.this.rendered
  # sensitive = true // comment this if you want to show the content to stdout
}
