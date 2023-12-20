output "ec2_instance_ids" {
  description = "Produced EC2 instance ids"
  value = {
    for k, v in aws_instance.this : k => v.id
  }
}
