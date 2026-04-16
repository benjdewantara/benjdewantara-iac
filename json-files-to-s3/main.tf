provider "aws" {
  profile = "benj"
  region  = "ap-southeast-1"
}

module "m01" {
  source = "./01a-create-s3-bucket"
}

module "m02" {
  source    = "./02a-upload-files-to-s3-bucket"
  s3_bucket = module.m01.bucket_name
}

output "m02_f" {
  value = module.m02.filepaths
}
