resource "aws_iam_role" "this" {
  name = "iamr-${local.friendlyname}"

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

resource "aws_iam_role_policy" "this" {
  name = "iamrp-${local.friendlyname}"
  role = aws_iam_role.this.name

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowS3",
          "Effect" : "Allow",
          "Action" : "s3:*",
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_instance_profile" "this" {
  name = "iamip-${local.friendlyname}"
  role = aws_iam_role.this.name
}

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
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data_template.sh")

  vars = {
    # still nothing for now
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon-linux-2023.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.aza_web.id
  security_groups = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name

  user_data = data.template_file.user_data.rendered

  tags = {
    Name    = "ec2-${local.friendlyname}"
    iacpath = "ec2-lambda-al2023-python3-12/ec2.tf"
  }

  lifecycle {
    create_before_destroy = true

    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      # security_groups,
    ]
  }
}