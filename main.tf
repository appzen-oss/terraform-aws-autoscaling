###
### Terraform AWS Autoscaling
###

# Documentation references:
#   https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html
#   https://www.terraform.io/docs/providers/aws/r/autoscaling_attachment.html
#   https://www.terraform.io/docs/providers/aws/r/autoscaling_lifecycle_hooks.html
#   https://www.terraform.io/docs/providers/aws/r/autoscaling_notification.html
#   https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html
#   https://www.terraform.io/docs/providers/aws/r/autoscaling_schedule.html
#   https://www.terraform.io/docs/providers/aws/r/launch_configuration.html

module "enabled" {
  source  = "devops-workflow/boolean/local"
  version = "0.1.1"
  value   = "${var.enabled}"
}

# Define composite variables for resources
module "label" {
  source        = "devops-workflow/label/local"
  version       = "0.2.1"
  attributes    = "${var.attributes}"
  component     = "${var.component}"
  delimiter     = "${var.delimiter}"
  environment   = "${var.environment}"
  monitor       = "${var.monitor}"
  name          = "${var.name}"
  namespace-env = "${var.namespace-env}"
  namespace-org = "${var.namespace-org}"
  organization  = "${var.organization}"
  owner         = "${var.owner}"
  product       = "${var.product}"
  service       = "${var.service}"
  tags          = "${var.tags}"
  team          = "${var.team}"
}

# NOTE: Terraform converts true to 1.
data "null_data_source" "tags_asg" {
  count = "${module.enabled.value ? length(keys(module.label.tags)) : 0}"

  inputs = "${map(
    "key", "${element(keys(module.label.tags), count.index)}",
    "value", "${element(values(module.label.tags), count.index)}",
    "propagate_at_launch", "true"
  )}"
}

locals {
  tags_asg = ["${data.null_data_source.tags_asg.*.outputs}"]
}

#######################
# Launch configuration
#######################
resource "aws_launch_configuration" "this" {
  count = "${module.enabled.value && var.launch_configuration == "" ? 1 : 0 }"

  name_prefix                 = "${coalesce(var.lc_name, module.label.id)}-"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  ebs_block_device            = "${var.ebs_block_device}"
  ebs_optimized               = "${var.ebs_optimized}"
  enable_monitoring           = "${var.enable_monitoring}"
  ephemeral_block_device      = "${var.ephemeral_block_device}"
  iam_instance_profile        = "${var.iam_instance_profile}"
  image_id                    = "${var.image_id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  placement_tenancy           = "${var.spot_price == "0" ? var.placement_tenancy : ""}"
  root_block_device           = "${var.root_block_device}"
  security_groups             = ["${var.security_groups}"]
  spot_price                  = "${var.spot_price == "0" ? "" : var.spot_price}"
  user_data                   = "${var.user_data}"

  lifecycle {
    create_before_destroy = true
  }
}

/*
# Attempt at improving the issue where it cannot delete the old LC on changes
resource "null_resource" "delay" {
  # count = 10
  depends_on = [
    "aws_launch_configuration.this"
  ]
  triggers {
    delay = "${aws_launch_configuration.this.name}"
  }
  lifecycle {
    create_before_destroy = true
  }
}
*/

####################
# Autoscaling group
####################
resource "aws_autoscaling_group" "this" {
  #depends_on = [
  #  "null_resource.delay"
  #]
  count = "${module.enabled.value}"

  name_prefix          = "${coalesce(var.asg_name, module.label.id)}-"
  launch_configuration = "${var.launch_configuration == "" ? element(concat(aws_launch_configuration.this.*.name, list("")), 0) : var.launch_configuration}"
  vpc_zone_identifier  = ["${var.vpc_zone_identifier}"]
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"

  load_balancers            = ["${var.load_balancers}"]
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"

  #availability_zones   = ["${var.availability_zones}"]
  default_cooldown          = "${var.default_cooldown}"
  enabled_metrics           = ["${var.enabled_metrics}"]
  force_delete              = "${var.force_delete}"
  metrics_granularity       = "${var.metrics_granularity}"
  min_elb_capacity          = "${var.min_elb_capacity}"
  placement_group           = "${var.placement_group}"
  protect_from_scale_in     = "${var.protect_from_scale_in}"
  suspended_processes       = "${var.suspended_processes}"
  tags                      = ["${local.tags_asg}"]
  target_group_arns         = ["${var.target_group_arns}"]
  termination_policies      = "${var.termination_policies}"
  wait_for_capacity_timeout = "${var.wait_for_capacity_timeout}"
  wait_for_elb_capacity     = "${var.wait_for_elb_capacity}"

  lifecycle {
    create_before_destroy = true
  }
}
