resource "aws_lambda_layer_version" "docker_python" {
  filename   = local.zip_full_filenamepath
  layer_name = "${local.friendlyname}"

  source_code_hash = filebase64sha256(local.zip_full_filenamepath)

  compatible_architectures = ["x86_64"]
  compatible_runtimes = ["python3.12"]

  skip_destroy = true
}