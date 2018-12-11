resource "aws_security_group" "site_security_group" {
  name        = "${var.sg_name}"
  description = "Security Group for ${var.sg_name}"
  vpc_id      = "${var.vpc_id}"

  // allows traffic from the SG itself for tcp
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

 // allow SSH traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.source_cidr_block}"]
  }

  // allow traffic to ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${var.alb_sec_group_id}"]
  }


  tags   = "${merge(var.tags, map("Name", "${var.sg_name}"))}"
}
