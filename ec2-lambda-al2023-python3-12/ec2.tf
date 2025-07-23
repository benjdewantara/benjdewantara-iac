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
          "Sid" : "iamrp-${local.friendlyname}-allow-s3",
          "Effect" : "Allow",
          "Action" : "s3:*",
          "Resource" : "*"
        }
      ]
    }
  )
}

# resource "aws_iam_policy" "this" {
#   name = "iamr-${local.friendlyname}"
#   policy = ""
# }

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

resource "aws_instance" "this" {

  ami                         = data.aws_ami.amazon-linux-2023.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.aza_web.id
  security_groups = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name

}