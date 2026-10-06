variable "aws_profile_this" { type = string }
variable "projectname" { type = string }

provider "aws" {
  profile = var.aws_profile_this
}

data "aws_caller_identity" "this" {}

locals {
}

# do `ssh-keygen -m PEM` on local
# give it the name for example `privkey.pem`
# then ssh-keygen will generate the `privkey.pem.pub`
data "local_file" "pubkey" {
  filename = "${path.module}/privkey.pem.pub"
}

resource "aws_key_pair" "this" {
  key_name   = var.projectname
  public_key = data.local_file.pubkey.content

  tags = {
    iacpath = "aws-keypair-onetime-1a/main.tf"
  }
}
