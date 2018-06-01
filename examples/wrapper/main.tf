provider "aws" {
  region = "${var.region}"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################
data "aws_vpc" "vpc" {
  tags {
    Env = "${var.environment}"
  }
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  name   = "default"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

/*
resource "aws_launch_configuration" "this" {
  name_prefix     = "${var.stack}_lc"
}
resource "aws_autoscaling_group" "this" {
  launch_configuration  = "${aws_launch_configuration.this.name}"
  # v0.11.2: lifecycle ignore_changes cannot contain interpolations
  lifecycle {
    ignore_changes        = ["desired_capacity"]
  }
}
/**/
######
# Launch configuration and autoscaling group
######
module "example" {
  source                      = "../../"
  name                        = "${var.stack}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  environment                 = "${var.environment}"
  iam_instance_profile        = "${var.instance_profile_id}"
  image_id                    = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${data.aws_security_group.default.id}"]
  spot_price                  = "${var.spot_price}"
  target_group_arns           = ["${var.target_group_arns}"]
  user_data                   = "${var.user_data}"

  enabled_metrics = [
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupTotalInstances",
  ]

  root_block_device = [
    {
      volume_size           = "${var.root_volume_size}"
      volume_type           = "gp2"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  asg_name                  = "${var.stack}_asg"
  desired_capacity          = "${var.desired_capacity}"
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  vpc_zone_identifier       = ["${data.aws_subnet_ids.all.ids}"]
  wait_for_capacity_timeout = 0

  tags = {
    Name    = "${var.stack} ASG"
    Project = "megasecret"
    Stack   = "${var.stack}"
  }
}
