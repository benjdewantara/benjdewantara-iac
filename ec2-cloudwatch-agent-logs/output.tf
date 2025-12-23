output "data-aws_ami-amazon-linux-2023-id" {
  value = data.aws_ami.amazon-linux-2023.id
}

output "aws_instance_id" {
  value = aws_instance.this.id
}
