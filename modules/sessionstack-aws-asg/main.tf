data "aws_caller_identity" "current" {}

data "aws_subnet" "subnet" {
  id = var.subnet_id
}

data "aws_ebs_volume" "sessionstack_data_storage" {
  filter {
    name   = "volume-id"
    values = [var.volume_id]
  }
}

resource "aws_iam_role" "sessionstack_storage_iam_role" {
  name = "SessionstackRoleStorageEBSAttachDetach"

  assume_role_policy = jsonencode({ Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "SessionstackStorageEBSAttachDetachPolicy"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "SessionstackStorageEBSAttachDetach",
          "Effect" : "Allow",
          "Action" : [
            "ec2:DetachVolume",
            "ec2:AttachVolume",
            "autoscaling:CompleteLifecycleAction"
          ],
          "Resource" : [
            "arn:aws:ec2:*:${data.aws_caller_identity.current.id}:instance/*",
            data.aws_ebs_volume.sessionstack_data_storage.arn,
            "arn:aws:autoscaling:*:${data.aws_caller_identity.current.id}:autoScalingGroup:*:autoScalingGroupName/*"
          ]
        }
      ]
    })
  }
}

resource "aws_iam_instance_profile" "sessionstack_storage_iam_instance_profile" {
  role = aws_iam_role.sessionstack_storage_iam_role.name
}

resource "aws_launch_template" "sessionstack_launch_template" {
  name          = "sessionstack_launch_template"
  instance_type = var.instance_type
  key_name      = var.key_name
  image_id      = var.ami

  iam_instance_profile {
    arn = aws_iam_instance_profile.sessionstack_storage_iam_instance_profile.arn
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
  }

  tag_specifications {
    resource_type = "instance"
    tags          = var.instance_tags
  }

  user_data = base64encode(
    templatefile("${path.module}/on_startup.sh.tmpl", {
      volume_id               = data.aws_ebs_volume.sessionstack_data_storage.id
      autoscalling_group_name = var.autoscalling_group_name
    })
  )
}

resource "aws_lb_target_group" "sessionstack_lb_target_group" {
  port        = 2733
  protocol    = "HTTP"
  vpc_id      = data.aws_subnet.subnet.vpc_id
  target_type = "instance"
}

resource "aws_autoscaling_group" "sessionstack_asg" {
  name                = var.autoscalling_group_name
  vpc_zone_identifier = [var.subnet_id]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  health_check_type   = "EC2"

  target_group_arns = [aws_lb_target_group.sessionstack_lb_target_group.arn]

  launch_template {
    id      = aws_launch_template.sessionstack_launch_template.id
    version = aws_launch_template.sessionstack_launch_template.latest_version
  }

  initial_lifecycle_hook {
    name                 = "attach-storage-volume-and-launch"
    default_result       = "ABANDON"
    heartbeat_timeout    = 300
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 0
      instance_warmup        = 0
    }
  }
}
