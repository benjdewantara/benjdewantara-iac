terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.36.0"
    }
  }
}
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

data "aws_availability_zone" "this" {
  name = "${var.aws_region}a"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "this" {
  vpc_id = data.aws_vpc.default.id
}

locals {
  availability_zone_single = "${var.aws_region}a"
}

resource "aws_db_instance" "example" {
  identifier        = "mylab-mysql-instance"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  username = "admin"
  password = "your-secure-password" # Consider using AWS Secrets Manager for production

  skip_final_snapshot = true
}

resource "aws_rds_cluster" "example" {
  cluster_identifier = "example"
  availability_zones = [local.availability_zone_single]
  engine             = "mysql"
  # db_cluster_instance_class = "db.r6gd.xlarge"
  # db_cluster_instance_class = "db.t4g.micro"
  db_cluster_instance_class = "db.t4g.large"
  storage_type              = "io1"
  allocated_storage         = 100
  iops                      = 1000
  master_username           = "test"
  master_password           = "mustbeeightcharaters"

  vpc_security_group_ids = [data.aws_security_group.this.id]
}

# resource "aws_rds_cluster" "this" {
#   database_name = var.projectname
#
#   engine                    = "mysql"
#   region                    = var.aws_region
#   allocated_storage         = 1
#   db_cluster_instance_class = "db.t4g.micro"
#   engine_version            = "8.4.9"
#   availability_zones        = [local.availability_zone_single]
#
# }

/*
Action=CreateDBInstance
Version=2014-10-31
DBInstanceIdentifier=database-1
DBInstanceClass=db.t4g.micro
Engine=mysql
DBName=
AllocatedStorage=20
MasterUsername=admin
MasterUserPassword=asdfasdf
VpcSecurityGroupIds.VpcSecurityGroupId.1=sg-07cb73cb816379e15
DBSubnetGroupName=default-vpc-0311e8a85d6dc6295
DBParameterGroupName=default.mysql8.4
BackupRetentionPeriod=1
Port=3306
MultiAZ=false
EngineVersion=8.4.9
AutoMinorVersionUpgrade=true
OptionGroupName=default%3Amysql-8-4
PubliclyAccessible=false
Tags=
StorageType=gp2
StorageEncrypted=true
CopyTagsToSnapshot=true
EnableIAMDatabaseAuthentication=false
EnableCloudwatchLogsExports=
DeletionProtection=false
MaxAllocatedStorage=1000
CACertificateIdentifier=rds-ca-rsa2048-g1
MultiTenant=false
EngineLifecycleSupport=open-source-rds-extended-support-disabled
*/

output "a27" {
  value = data.aws_availability_zone.this.name
}
