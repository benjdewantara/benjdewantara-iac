provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

data "aws_availability_zone" "this" {
  name = "${var.aws_region}a"
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

resource "aws_db_subnet_group" "this" {
  subnet_ids = slice(data.aws_subnets.this.ids, 0, 2)
}

output "a64" {
  value = aws_db_subnet_group.this
}

resource "aws_db_instance" "this" {
  db_name           = var.projectname
  identifier        = var.projectname
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t4g.micro"
  allocated_storage = 5
  # storage_type      = "gp2"

  username = "admin"
  password = "your-secure-password" # Consider using AWS Secrets Manager for production

  skip_final_snapshot = true
  # vpc_security_group_ids = [data.vpc.default_security_group_id]
  db_subnet_group_name = aws_db_subnet_group.this.name
}

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
