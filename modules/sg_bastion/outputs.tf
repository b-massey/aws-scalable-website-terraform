output "security_group_id" {
  value = "${aws_security_group.bastion_security_group.id}"
}