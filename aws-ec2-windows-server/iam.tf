resource "aws_iam_role" "this" {
  name = "${var.projectname}-ssm-instance-management"

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
            "ec2.amazonaws.com",
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this_ssm1" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
}

resource "aws_iam_instance_profile" "this" {
  name = aws_iam_role.this.name
  role = aws_iam_role.this.name
}
