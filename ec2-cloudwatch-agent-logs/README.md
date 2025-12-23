# Tips

1. Check the log file `/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log` 
  if you want to find out 
  why the `CWAgent` namespace 
  is not created yet on AWS Console - CloudWatch 
1. Certain permissions from these two (possibly three) 
  may be needed:
    - EC2 (ec2:*)
    - CloudWatch (cloudwatch:*)
    - CloudWatchLogs (logs:*)
1. CloudWatch agent cannot read a file within `/home/ec2-user` directory

