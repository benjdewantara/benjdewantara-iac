provider "azuread" {
  tenant_id = var.tenant_id
}

data "azuread_client_config" "current" {}

resource "azuread_application" "this" {
  display_name            = var.app_display_name
  prevent_duplicate_names = true

  sign_in_audience = "AzureADMyOrg"

  lifecycle {
    ignore_changes = [
      app_role,
    ]
  }

  feature_tags {
    custom_single_sign_on = true
    # gallery               = false
    enterprise = true
  }

  # app_role {
  #   allowed_member_types = ["User", "Application"]
  #   description          = "This is What.What"
  #   display_name         = "What.WhatDisplay_name"
  #   value                = "What.WhatValue"
  #   id                   = random_uuid.this.id
  # }
}

resource "azuread_service_principal" "this" {
  client_id = azuread_application.this.client_id
}

# resource "azuread_application_redirect_uris" "this" {
#   application_id = azuread_application.this.id
#   redirect_uris  = ["http://localhost:1234/callback"]
#   type           = "Web"
# }

resource "azuread_application_password" "this" {
  application_id = azuread_application.this.id
}

resource "random_uuid" "this" {}

output "a36" {
  value = jsonencode(azuread_application.this)
}

# resource "local_file" "a36" {
#   filename = "/home/benjdewantara/Documents/benjdewantara-iac/scratch-json01.json"
#   content  = jsonencode(azuread_application.this)
# }

resource "azuread_application_app_role" "this_What_What1" {
  application_id = azuread_application.this.id
  role_id        = random_uuid.this.id

  value                = "What.WhatValue"
  display_name         = "What.WhatDisplay_name"
  description          = "This is What.What"
  allowed_member_types = ["User", "Application"]
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
# client_id=dd112379-19a5-44ae-8dbf-a1f973aac335/password/79a56d06-9f0c-4c8c-81b1-777bb938352b

output "client_secrets_id_file_content" {
  value = data.template_file.this.rendered
  # sensitive = true // comment this if you want to show the content to stdout
}
# 87f7da99-d436-4073-a47d-bbd48f2e8dd8
# 04b07795-8ddb-461a-bbee-02f9e1bf7b46
# be4c296a-adfe-4a51-b1cb-d6cfb385584d
