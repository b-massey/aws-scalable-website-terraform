resource "aws_autoscaling_group" "web_asg" {
  name                      = "${format("asg-%s",var.name)}"
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  desired_capacity          = "${var.desired_capacity}"
  vpc_zone_identifier       = ["${split(",", var.vpc_zone_identifier)}"]
  launch_template		    = {
  	id 		= "${var.launch_template_id}"
  	version = "$$Latest"
  }

  
}