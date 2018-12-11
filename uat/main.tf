
provider "aws" {
  region     = "${var.region}"
}

data "aws_ami" "linux" {
  most_recent = true  
  filter {
    name   = "description"
    values = ["* Linux *"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}



module "vpc" {
  source                = "../modules/vpc"
  name                  = "${format("%s-%s",var.project_name,var.env_name)}"
  cidr                  = "${var.vpc_cidr}"
  azs                   = "eu-west-2a,eu-west-2b"
  tags                  = "${merge(map("Env",var.env_name),var.web_tags)}"
  public_subnets        = "${cidrsubnet(var.vpc_cidr,2,0)},${cidrsubnet(var.vpc_cidr,2,1)}"
  private_subnets       = "${cidrsubnet(var.vpc_cidr,2,2)},${cidrsubnet(var.vpc_cidr,2,3)}"
  enable_dns_hostnames  = "true"
  enable_dns_support    = "true"
}

module "sg_alb" {
  source            = "../modules/sg_alb"
  sg_name           = "${format("%s-%s-alb",var.project_name,var.env_name)}"
  vpc_id            = "${module.vpc.vpc_id}"
  source_cidr_block = "0.0.0.0/0"
  tags              = "${merge(map("Env",var.env_name),var.web_tags)}"
}

module "sg_site" {
  source            = "../modules/sg_site"
  sg_name           = "${format("%s-%s",var.project_name,var.env_name)}"
  vpc_id            = "${module.vpc.vpc_id}"
  alb_sec_group_id  = "${module.sg_alb.security_group_id}"
  source_cidr_block = "0.0.0.0/0"
  tags              = "${merge(map("Env",var.env_name),var.web_tags)}"
}

module "alb" {
  source              = "../modules/alb"
  name                = "${format("%s-%s",var.project_name,var.env_name)}"
  tags                = "${merge(map("Env",var.env_name),var.web_tags)}"
  subnets             = "${module.vpc.public_subnets}"
  security_groups     = "${module.sg_alb.security_group_id}"
  vpc_id              = "${module.vpc.vpc_id}"
  target_port         = "80"
  target_protocol     = "HTTP"  
  listening_port      = "80"
  listening_protocol  = "HTTP"
}

module "launch_template" {
  source                = "../modules/launch_template"
  name                  = "${format("%s-%s",var.project_name,var.env_name)}"
  tags                  = "${merge(map("Env",var.env_name),var.web_tags)}"
  ami                   = "${data.aws_ami.linux.id}"
  instance_type         = "${var.instance_type}"
  security_groups       = "${module.sg_site.security_group_id}"
  key_name              = "${var.key_pair}"
  websiteFilesS3Bucket  = "${var.site_s3Bucket}"
 
}

module "autoscaling_groups" {
  source              = "../modules/autoscaling_groups"
  name                = "${format("%s-%s",var.project_name,var.env_name)}"
  min_size            = "1"
  max_size            = "2"
  desired_capacity    = "1"
  vpc_zone_identifier = "${module.vpc.private_subnets}"
  launch_template_id  = "${module.launch_template.web_launch_template_id}"
  tags                = "${merge(map("Env",var.env_name),var.web_tags)}"
}