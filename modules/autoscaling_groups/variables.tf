
variable "name" {}
variable "min_size" {}
variable "max_size" {}
variable "desired_capacity" {}
variable "vpc_zone_identifier" {}
variable "launch_template_id" {}
#variable "health_check_grace_period" {}
#variable "health_check_type" {}
#variable "force_delete" {}
#variable "enabled_metrics" {}
variable "tags" {
    type = "map"
}