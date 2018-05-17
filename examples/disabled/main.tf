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

######
# Launch configuration and autoscaling group
######
module "example" {
  source  = "../../"
  name    = "example-with-ec2"
  enabled = false

  # Launch configuration
  #
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  #lc_name = "example-lc"
  environment = "${var.environment}"

  image_id                    = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "t2.micro"
  security_groups             = ["${data.aws_security_group.default.id}"]
  associate_public_ip_address = true

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size           = "50"
      volume_type           = "gp2"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  #asg_name                  = "example-asg"
  vpc_zone_identifier = ["${data.aws_subnet_ids.all.ids}"]

  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = {
    Project = "megasecret"
  }
}
