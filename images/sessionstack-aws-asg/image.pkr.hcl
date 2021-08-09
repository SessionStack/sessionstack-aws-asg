variable "region" { type = string }
variable "subnet_id" { type = string }
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "aws-sessionstack" {
  ami_name      = "aws-sessionstack-${local.timestamp}"
  instance_type = "t2.medium"

  region                      = var.region
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  source_ami_filter {
    filters = {
      name = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 40
  }

  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.aws-sessionstack"]

  provisioner "file" {
    destination = "/tmp"
    source      = "${path.root}/files"
  }

  provisioner "shell" {
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    script          = "${path.root}/on_build.sh"
  }
}
