
provider "aws" {
  region     = "${var.region}"
}

data "aws_ami" "linux" {
  most_recent = true  
  filter {
    name   = "description"
    values = ["*Amazon Linux *"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}



module "vpc" {
  source                = "git@github.com:b-massey/terraform-modules.git//aws/networking/vpc"
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
  source            = "git@github.com:b-massey/terraform-modules.git//aws/networking/security_groups/sg_alb"
  sg_name           = "${format("%s-%s-alb",var.project_name,var.env_name)}"
  vpc_id            = "${module.vpc.vpc_id}"
  source_cidr_block = "0.0.0.0/0"
  tags              = "${merge(map("Env",var.env_name),var.web_tags)}"
}

module "sg_site" {
  source            = "git@github.com:b-massey/terraform-modules.git//aws/networking/security_groups/sg_site"
  sg_name           = "${format("%s-%s",var.project_name,var.env_name)}"
  vpc_id            = "${module.vpc.vpc_id}"
  alb_sec_group_id  = "${module.sg_alb.security_group_id}"
  source_cidr_block = "0.0.0.0/0"
  tags              = "${merge(map("Env",var.env_name),var.web_tags)}"
}

module "sg_bastion" {
  source              = "git@github.com:b-massey/terraform-modules.git//aws/networking/security_groups/sg_bastion"
  sg_name             = "sg_bastion"
  vpc_id              = "${module.vpc.vpc_id}"
  source_cidr_block   = "0.0.0.0/0"
  restricted_access   = "84.233.151.245/32"
  tags                = "${merge(map("Env",var.env_name),var.web_tags)}"
}

module "bastion_server" {
  source                      = "git@github.com:b-massey/terraform-modules.git//aws/ec2/bastion_server"
  ami                         = "${data.aws_ami.linux.id}"
  instance_type               = "t2.small"
  key_name                    = "${var.key_pair}"
  security_groups             = "${module.sg_bastion.security_group_id}"
  subnet_id                   = "${module.vpc.public_subnets}"
  associate_public_ip_address = "true"
  source_dest_check           = "false"
  tags                        = "${merge(map("Env",var.env_name),var.web_tags)}"
}

module "alb" {
  source              = "git@github.com:b-massey/terraform-modules.git//aws/ec2/alb"
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
  source                = "git@github.com:b-massey/terraform-modules.git//aws/ec2/launch_template"
  name                  = "${format("%s-%s",var.project_name,var.env_name)}"
  tags                  = "${merge(map("Env",var.env_name),var.web_tags)}"
  ami                   = "${data.aws_ami.linux.id}"
  instance_type         = "${var.instance_type}"
  security_groups       = "${module.sg_site.security_group_id}"
  key_name              = "${var.key_pair}"
  websiteFilesS3Bucket  = "${var.site_s3Bucket}"
 
}

module "autoscaling_groups" {
  source              = "git@github.com:b-massey/terraform-modules.git//aws/ec2/autoscaling_groups"
  name                = "${format("%s-%s",var.project_name,var.env_name)}"
  min_size            = "1"
  max_size            = "2"
  desired_capacity    = "1"
  vpc_zone_identifier = "${module.vpc.private_subnets}"
  launch_template_id  = "${module.launch_template.web_launch_template_id}"
  tags                = "${merge(map("Env",var.env_name),var.web_tags)}"
}
