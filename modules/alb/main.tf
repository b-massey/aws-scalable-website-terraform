resource "aws_alb" "web_alb" {
  name                       = "${var.name}-alb"
  internal                   = false
  security_groups            = ["${var.security_groups}"]
  subnets                    = ["${split(",", var.subnets)}"]
  enable_deletion_protection = false
  
}


# Target containers are registered by the ECS service
resource "aws_alb_target_group" "web_tgrp" {
  name                 = "${var.name}-tgrp"
  port                 = "${var.target_port}"
  protocol             = "${var.target_protocol}"
  vpc_id               = "${var.vpc_id}"
  depends_on           = ["aws_alb.web_alb"]
  tags                 = "${merge(var.tags, map("Name", format("%s-tgrp",var.name)))}"
/*
  health_check {
    path                = "/mnt"
    healthy_threshold   = "${var.healthy_threshold}"
    unhealthy_threshold = "${var.unhealthy_threshold}"
    interval            = "${var.interval}"
    matcher             = "${var.matcher}"
  }
  */
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.web_alb.arn}"
  port              = "${var.listening_port}"
  protocol          = "${var.listening_protocol}"

  default_action {
    target_group_arn = "${aws_alb_target_group.web_tgrp.arn}"
    type             = "forward"
  }
}
