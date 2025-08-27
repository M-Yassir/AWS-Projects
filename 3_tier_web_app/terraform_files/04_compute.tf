# get the AMI of ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] 
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
}

# the launch template of the presentation tier
resource "aws_launch_template" "public_launch_template" {
    name_prefix = "public-launch-template"
    image_id = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    key_name = "my_key"
    network_interfaces {
        security_groups = [aws_security_group.Frontend_SG.id]
        associate_public_ip_address = true
        delete_on_termination = true
    }
    user_data = base64encode(templatefile("${path.module}/scripts/frontend-userdata.sh", {
    backend_alb_dns = aws_lb.internal_alb.dns_name
    }))
}

# the launch template of the application tier
resource "aws_launch_template" "private_launch_template" {
    name_prefix = "private-launch-template"
    image_id = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    key_name = "my_key"
    network_interfaces {
        security_groups = [aws_security_group.Backend_SG.id]
        associate_public_ip_address = false
        delete_on_termination = true
    }
    user_data = base64encode(templatefile("${path.module}/scripts/backend-userdata.sh", {
    db_host     = aws_db_instance.main.address
    db_name     = aws_db_instance.main.db_name
    db_username = aws_db_instance.main.username
    db_password = var.db_password
  }))
}

# the auto scaling group of the presentation tier
resource "aws_autoscaling_group" "public_autoscaling_group" {
    name = "public-autoscaling-group"
    launch_template {
        id = aws_launch_template.public_launch_template.id
        version = "$Latest"
    }
    # Register instances with the external ALB target group
    target_group_arns = [aws_lb_target_group.frontend_tg.arn]

    vpc_zone_identifier = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    min_size = 2 
    max_size = 4
    desired_capacity = 2

    # Health check settings
    health_check_type         = "ELB"
    health_check_grace_period = 300

    tag {
        key                 = "Name"
        value               = "frontend-instance"
        propagate_at_launch = true
    }
}


# the auto scaling group of the application tier
resource "aws_autoscaling_group" "private_autoscaling_group" {
    name = "private-autoscaling-group"
    launch_template {
        id = aws_launch_template.private_launch_template.id
        version = "$Latest"
    }
    # Register instances with the target group
    target_group_arns = [aws_lb_target_group.backend_tg.arn]

    vpc_zone_identifier = [aws_subnet.private_subnet_3.id, aws_subnet.private_subnet_4.id]
    min_size = 2
    max_size = 4
    desired_capacity = 2
    tag {
        key                 = "Name"
        value               = "backend-instance"
        propagate_at_launch = true
    }
    # Health check settings
    health_check_type         = "ELB"
}