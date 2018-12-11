resource "aws_security_group" "alb_security_group" {
  name        = "${var.sg_name}"
  description = "ALB Security Group"
  vpc_id      = "${var.vpc_id}"

  // allows traffic from the SG itself for tcp
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  /*
  // allows traffic from the SG itself for udp
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    self      = true
  }
  */

  // allow traffic on port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.source_cidr_block}"]
  }

/*
  // allow node to call out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.source_cidr_block}"]
  }
  */

  tags   = "${merge(var.tags, map("Name", "${var.sg_name}"))}"
}
