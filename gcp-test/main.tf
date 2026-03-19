provider "google" {
  project = "heroic-passkey-317306"
}

resource "google_service_account" "service_account" {
  project      = "heroic-passkey-317306"
  account_id   = "service-account-id"
  display_name = "Service Account"
}
