resource "aws_secretsmanager_secret" "this" {
  name = local.secretsmanager_name
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = local.secret_value
}

# data "aws_secretsmanager_secret" "this" {
#   name = local.secretsmanager_name
# }
#
# resource "aws_secretsmanager_secret_version" "this" {
#   secret_id     = data.aws_secretsmanager_secret.this.id
#   secret_string = local.secret_value
# }
