resource "aws_secretsmanager_secret" "this" {
  name = local.secretsmanager_name
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = "This is the secret_string"
}
