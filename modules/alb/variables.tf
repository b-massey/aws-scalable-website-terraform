variable "name" {}
variable "security_groups" {}
variable "subnets" {}
variable "tags" {
    type = "map"
}
variable "vpc_id" {}
variable "target_port" {}
variable "target_protocol" {}
variable "listening_port" {}
variable "listening_protocol" {}

/*
variable "matcher" {}

variable "healthy_threshold" {}
variable "unhealthy_threshold" {}
variable "interval" {}
variable "idle_timeout" {}

*/