
variable "sg_name" {}
variable "vpc_id" {}
variable "source_cidr_block" {}
variable "restricted_access" {}
variable "tags" {
    type = "map"
}