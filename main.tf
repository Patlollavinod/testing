provider "aws" {
    region = var.aws_region
}

resource "aws_instance" "ec2" {
    ami = var.ec2_ami
    instance_type = var.instance_type
    key_name = var.ec2_keypair
    count = var.ec2_count
    vpc_security_group_ids = var.vpc_security_group
    subnet_id = element(var.subnets, count.index)
    tags = {
        Name = "${var.environment}.${var.product}-${count.index}"
    }
}

resource "aws_lb_target_group" "my-target-group" {
    health_check {
        interval =              10
        path =                  "/"
        protocol =              "HTTP"
        timeout =               5
        healthy_threshold =     5
        unhealthy_threshold =   2
    }
    name =          "terraform-tg"
    port =           80
    protocol =      "HTTP"
    target_type =   "instance"
    vpc_id =        "${var.vpc_id}"
}

resource "aws_lb" "my-aws-alb" {
  name =            "my-alb"
  internal =        false
  security_groups = var.vpc_security_group
  subnets =        ["subnet-0bee8832e401ccc6b", "subnet-01d1fa65065bf0797"]
  tags = {
    Name = "My-Alb"
  }
  ip_address_type     = "ipv4"
  load_balancer_type  = "application"
}

resource "aws_lb_listener" "my-test-alb-listner" {
    load_balancer_arn = "${aws_lb.my-aws-alb.arn}"
    port =              80
    protocol =          "HTTP"
    default_action {
        type =          "forward"
        target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
    }
}

resource "aws_launch_configuration" "test"  {
    name_prefix = "new-lc"
    image_id = "${var.ec2_ami}"
    instance_type = "${var.instance_type}"
    key_name= "${var.ec2_keypair}"
    security_groups = var.vpc_security_group
    associate_public_ip_address = true
}

resource "aws_autoscaling_group" "my-asg" {
    name = "${aws_launch_configuration.test.name}"
    min_size=1
    desired_capacity = 1
    max_size = 2
    health_check_type = "ELB"
    launch_configuration      = "${aws_launch_configuration.test.name}"
    target_group_arns = ["${aws_lb_target_group.my-target-group.arn}"]
    vpc_zone_identifier       = [
        "subnet-0bee8832e401ccc6b", 
        "subnet-01d1fa65065bf0797" 
    ]
    # required to redploy without an outage.
    lifecycle {
        create_before_destroy = true
    }
    tag {
        key ="name"
        value = "my-asg"
        propagate_at_launch = true
}
}
