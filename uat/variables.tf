variable "region" {
	description = "AWS Region."
  	default = "eu-west-2"
}


variable "project_name" {
	description = "Project Name."
  	default = "epsum"
}

variable "env_name" {
	description = "Environment"
  	default = "uat"
}

variable "web_tags" {
  type = "map"

  default = {
    "cost-centre" = "OPS"
    "Team"        = "Web-Ops"
    "app"         = "epsum-web-site"
  }
} 


variable "vpc_cidr" {
	description = "CIDR for the VPC."
  	default = "172.21.1.0/24"
}


# Instance 
variable "instance_type" {
	description = "Instance Type."
  	default = "t2.micro"
}
variable "key_pair" {
	description = "Key Pair"
  	default = "bindu-massey-sandbox"
}

# Site Files
variable "site_s3Bucket" {
  description = "S3 bucket with Website files"
    default = "bm-terraform-testsite/sitefiles"
}

