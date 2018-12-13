# IAM Policy
data "aws_iam_policy_document" "instance-s3-read-policy" {
  statement {
    actions = [
      "s3:Get*", 
      "s3:List*"
    ]
   resources = [ "*" ]
  }
}

# IAM Role
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#User data
data "template_file" "user_data" {
  template = <<EOF
#!/bin/bash -xe
  yum update -y
  yum install httpd -y
  service httpd start
  chkconfig httpd on
  aws s3 cp s3://"${var.websiteFilesS3Bucket}" /var/www/html --recursive  
EOF
}

resource "aws_iam_role" "web_instance_role" {
  name               = "web_instance_role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
  tags =  "${merge(var.tags, map("Name", "web_instance_role"))}"
}

# EC2 Instance Role Policy
resource "aws_iam_role_policy" "web_instance_role_policy" {
  name   = "web_instance_role_policy"
  policy = "${data.aws_iam_policy_document.instance-s3-read-policy.json}"
  role   = "${aws_iam_role.web_instance_role.id}"
}

# Instance Profile
resource "aws_iam_instance_profile" "web_instance_profile" {
  name = "web_instance_profile"
  role = "${aws_iam_role.web_instance_role.name}"
}

#launch_template
resource "aws_launch_template" "web_launch_template" {
  name = "${format("launch-template-%s",var.name)}"


  iam_instance_profile = { name = "${aws_iam_instance_profile.web_instance_profile.name}" }
  image_id                  = "${var.ami}"
  instance_type             = "${var.instance_type}"
  key_name                  = "${var.key_name}"
  vpc_security_group_ids    = ["${var.security_groups}"]

  instance_initiated_shutdown_behavior = "terminate"
  instance_market_options {
    market_type = "spot"
  }
  

  tag_specifications {
    resource_type = "instance"
    tags =  "${merge(var.tags, map("Name", format("%s-instance",var.name)))}"
  }
  user_data = "${base64encode(data.template_file.user_data.rendered)}"
}