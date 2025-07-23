provider "aws" {
  profile = "benj"
  region  = "ap-southeast-1"
}

locals {
  friendlyname          = "benj-docker-python3-12new"
  zip_full_filenamepath = "./docker-python3.12new.benj.zip"
}
