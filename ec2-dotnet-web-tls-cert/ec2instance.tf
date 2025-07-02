data "aws_ami" "amazon-linux-2023" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name = "name"
    values = ["al2023-ami-2023.*"]
    # values = ["al2023-ami-minimal-2023.*"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data_template.sh")

  vars = {
    git_dotnet_project        = local.git_dotnet_project
    git_dotnet_project_subdir = local.git_dotnet_project_subdir
    app_url_https             = local.app_url_https
    s3_uri_cert               = local.s3_uri_cert
    s3_uri_cert_private_key   = local.s3_uri_cert_private_key
    s3_bucket_region_cert     = local.s3_bucket_region_cert
  }
}

resource "aws_iam_role" "this" {
  name = "iamr-${local.friendlyname}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole",
        ],
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "this" {
  name = "iampolicy_inline_iamrole_benj_web"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : ["s3:*", "kms:*"],
        "Resource" : "*"
      }
    ]
  })

  role = aws_iam_role.this.name
}

resource "aws_iam_role_policies_exclusive" "example" {
  role_name = aws_iam_role.this.name
  policy_names = [aws_iam_role_policy.this.name]
}

resource "aws_iam_instance_profile" "this" {
  name = "iamip-${local.friendlyname}"
  role = aws_iam_role.this.name
}

resource "aws_instance" "this" {
  # depends_on = [aws_route53_record.this, aws_route53_record.this_www]
  depends_on = [aws_security_group.this]

  ami                         = data.aws_ami.amazon-linux-2023.image_id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.aza_web.id
  security_groups = [aws_security_group.this.id]
  iam_instance_profile = aws_iam_instance_profile.this.name
  # key_name                    = var.ec2_keypair_name

  user_data = data.template_file.user_data.rendered

  tags = {
    Name    = "ec2-${local.friendlyname}"
    iacpath = "${local.friendlyname}/ec2instance.tf"
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      security_groups,
    ]
  }
}
