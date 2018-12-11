
output "alb_id" {
  value = "${aws_alb.web_alb.id}"
}

output "aws_alb_target_group" {
  value = "${aws_alb_target_group.web_tgrp.id}"
}