# Overview

This is a terraform module + image used to deploy a single instance docker compose sessionstack instance in AWS EC2. It creates an autoscalling group with a single membere that has an EBS volume attached to it. In case of error due to EC2 the instance gets terminated and the autoscaller ensures it creates another instance with the same image having the same EBS volume attach to it. This results in self healing sessionstack single node configuration.


# Usage


1. Copy `./example/images/sessionstack-aws-asg/files` to `./image/sessionstack-aws-asg/files` and modify them for your use case.

2. Build the AMI with everything needed to run a sessionstack services image.

`packer build -var 'region=[REGION]' -var 'subnet_id=[SUBNET_ID]' ./images/sessionstack-aws-asg/image.pkr.hcl`

3. Copy `./examples/main.tf` to `./main.tf` and modify it to your use case.

4. Modify your `./main.tf` to include the proper `AMI` id generated from `Packer`

5. Initialize the terraform play

`terraform init`

6. Apply the terraform play

`terraform apply`

7. Terminate forcefully your instance to validate the autoscalling group is working

`aws autoscaling terminate-instance-in-auto-scaling-group --instance-id [INSTANCE_ID] --no-should-decrement-desired-capacity`
