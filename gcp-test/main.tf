provider "google" {
  project = "heroic-passkey-317306"
  # region      = "us-central1"
}

# provider "google" {
#   impersonate_service_account = "svcacc01a@heroic-passkey-317306.iam.gserviceaccount.com"
# }

resource "google_service_account" "service_account" {
  project      = "heroic-passkey-317306"
  account_id   = "service-account-id"
  display_name = "Service Account"
}

# resource "google_iam_oauth_client" "example" {
#   project               = "heroic-passkey-317306"
#   oauth_client_id       = "example-client-id"
#   display_name          = "Display Name of OAuth client"
#   description           = "A sample OAuth client"
#   location              = "global"
#   disabled              = false
#   allowed_grant_types   = ["AUTHORIZATION_CODE_GRANT"]
#   allowed_redirect_uris = ["https://www.example.com"]
#   allowed_scopes        = ["https://www.googleapis.com/auth/cloud-platform"]
#   client_type           = "CONFIDENTIAL_CLIENT"
# }
