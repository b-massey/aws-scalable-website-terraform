output "vpc_id" {
	value ="${aws_vpc.web_vpc.id}"
}

output "private_subnets" {
	value = "${join(",",aws_subnet.private.*.id)}"
}

output "public_subnets" {
	value = "${join(",",aws_subnet.public.*.id)}"
}

output "nat_gateway_id" {
	value = "${aws_nat_gateway.nat_gw.id}"
}