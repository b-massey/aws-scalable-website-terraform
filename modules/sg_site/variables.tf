
variable "sg_name" {}
variable "vpc_id" {}
variable "source_cidr_block" {}
variable "alb_sec_group_id" {}
variable "tags" {
    type = "map"
}