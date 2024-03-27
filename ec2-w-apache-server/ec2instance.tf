data "template_file" "user_data_ec2_instance" {
  template = file("./user_data.sh")

  vars = {
    domainNameThis = local.domain_name_public
    email_certbot  = local.email_certbot
  }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_ami" "amazon-linux-2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*"]
    # values = ["al2023-ami-minimal-2023.*"]
  }
}

resource "aws_iam_role" "this" {
  name = "iamr-${local.friendlyname}"

  inline_policy {
    name   = "iampolicy_inline_iamrole_benj_web"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : "s3:*",
          "Resource" : "*"
        }
      ]
    })
  }

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
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

resource "aws_iam_instance_profile" "this" {
  name = "iamip-${local.friendlyname}"
  role = aws_iam_role.this.name
}

resource "aws_instance" "this" {
  depends_on = [aws_route53_record.this, aws_route53_record.this_www]

  ami                         = data.aws_ami.amazon-linux-2.image_id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.aza_web.id
  security_groups             = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  # key_name                    = var.ec2_keypair_name

  user_data = data.template_file.user_data_ec2_instance.rendered
  # user_data_base64 = filebase64("./user_data.sh")

  tags = {
    Name    = "ec2-${local.friendlyname}"
    iacpath = "benj-apache-wkwk/main.tf"
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
       security_groups,
    ]
  }
}

