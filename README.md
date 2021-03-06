# AWS Auto Scaling Group (ASG) Terraform module

[![CircleCI](https://circleci.com/gh/devops-workflow/terraform-aws-autoscaling/tree/master.svg?style=svg)](https://circleci.com/gh/devops-workflow/terraform-aws-autoscaling/tree/master)
[![Github release](https://img.shields.io/github/release/devops-workflow/terraform-aws-autoscaling.svg)](https://github.com/devops-workflow/terraform-aws-autoscaling/releases)

Terraform module which creates Auto Scaling resources on AWS.

These types of resources are supported:

* [Launch Configuration](https://www.terraform.io/docs/providers/aws/r/launch_configuration.html)
* [Auto Scaling Group](https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html)

## TODO

* Update README with changes in this fork

## Usage

```hcl
module "asg" {
  source = "devops-workflow/autoscaling/aws"

  name = "service"

  # Launch configuration
  lc_name = "example-lc"

  image_id        = "ami-ebd02392"
  instance_type   = "t2.micro"
  security_groups = ["sg-12345678"]

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
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "example-asg"
  vpc_zone_identifier       = ["subnet-1235678", "subnet-87654321"]
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "megasecret"
      propagate_at_launch = true
    },
  ]
}
```

## Conditional creation

Normally this module creates both Auto Scaling Group (ASG) and Launch
Configuration (LC), and connect them together. It is possible to customize
this behavior passing different parameters to this module:

1. To create ASG, but not LC. Associate ASG with an existing LC:

```hcl
create_lc = false
launch_configuration = "existing-launch-configuration"
```

1. To create LC, but not ASG. Outputs may produce errors.

```hcl
create_asg = false
```

1. To disable creation of both resources (LC and ASG) you can specify both arguments `create_lc = false` and `create_asg = false`. Sometimes you need to use this way to create resources in modules conditionally but Terraform does not allow to use `count` inside `module` block.

## Examples

* [Auto Scaling Group without ELB](https://github.com/terraform-aws-modules/terraform-aws-autoscaling/tree/master/examples/asg_ec2)
* [Auto Scaling Group with ELB](https://github.com/terraform-aws-modules/terraform-aws-autoscaling/tree/master/examples/asg_elb)

## Authors

This fork managed by [Steven Nemetz](ttps://github.com/snemetz)

Upstream module managed by [Anton Babenko](https://github.com/antonbabenko).

## License

Apache 2 Licensed. See LICENSE for full details.
