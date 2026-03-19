locals {
  project = "heroic-passkey-317306"
}

provider "google" {
  project = local.project
}

resource "google_service_account" "service_account" {
  project      = local.project
  account_id   = "something-id"
  display_name = "Service Account"
}
