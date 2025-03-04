terraform {
  source = "../shared"
}

dependency "foo" {
  config_path = "../foo"
}

inputs = {
  nickname = "bar-after-${dependency.foo.outputs.output_bucket_name}"
}