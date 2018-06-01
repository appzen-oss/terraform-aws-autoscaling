variable "environment" {
  default = "one"
}

variable "region" {
  default = "us-west-2"
}

variable "associate_public_ip_address" {
  description = "Add a public IP address"
  default     = false
}

variable "desired_capacity" {
  description = "Desired number of instances"
  default     = 1
}

variable "health_check_grace_period" {
  description = "Auto Scaling Group health check grace period in seconds. Time allowed before starting to test the health check"
  default     = "300"
}

variable "health_check_type" {
  description = "Healthcheck type"
  default     = "ELB"
}

variable "instance_profile_id" {
  description = "Instance profile ID"
  default     = ""
}

variable "instance_type" {
  description = "Instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key name to use"
  default     = "devops20170606"
}

variable "max_size" {
  description = "Maximum number of instances"
  default     = 2
}

variable "min_size" {
  description = "Minimum number of instances"
  default     = 1
}

variable "root_volume_size" {
  description = "Size of the root volume"
  default     = 8
}

variable "spot_price" {
  description = "Spot price. Set to false to not use spot pricing"
  default     = false
}

variable "stack" {
  description = "Name of the service stack"
  default     = "wrapper-test"
}

variable "tags" {
  description = "Map of tags"
  type        = "map"
  default     = {}
}

variable "target_group_arns" {
  description = "List of target group ARNs"
  type        = "list"
  default     = []
}

variable "user_data" {
  description = "User data script"
  default     = " "
}
