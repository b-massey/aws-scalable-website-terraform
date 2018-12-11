variable "name" {}
variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "security_groups" {}
variable "websiteFilesS3Bucket" {}
variable "tags" {
    type = "map"
}