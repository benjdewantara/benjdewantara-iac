provider "aws" {
  profile = "benj"
  region  = "ap-southeast-1"
}

locals {
  friendlyname = "bnj-build-lambda-layer"
}
