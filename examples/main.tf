terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "KEY_NAME"
  public_key = "PUBLIC_KEY"
}

module "sessionstack-aws-asg" {
  source = "./modules/sessionstack-aws-asg"

  key_name                    = aws_key_pair.ssh-key
  subnet_id                   = "subnet-EXAMPLE"
  instance_type               = "t2.medium"
  instance_tags               = { Name = "Sessionstack Service Instance" }
  associate_public_ip_address = true
  autoscalling_group_name     = "Sessionstack Service ASG"

  volume_id = "vol-ID"

  ami = "ami-ID"
}
