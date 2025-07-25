provider "aws" {
  profile = "benj"
  region  = "ap-southeast-1"
}

locals {
  friendlyname = "bnj-nodejs-selftutorial"

  s3_uri_dump_results = ""
  s3_uri_dump_results_trimmed = trim(local.s3_uri_dump_results, "/")

  git_repo_url = "https://github.com/benjdewantara/bnj-nextjs-samples.git"
  git_branch   = "howto/nodejs+npm"
}
