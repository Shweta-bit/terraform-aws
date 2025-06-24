# output "subnet_id" {
#   value = aws_subnet.public.id
# }

output "public_subnet_ids" {
  value = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}


output "sg_id" {
  value = aws_security_group.allow_ssh.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "route_table_id" {
  value = aws_route_table.public
}



output "nat_gateway_id"{
  value = aws_nat_gateway.nat_gw.id
}

output "nat_eip"{
  value = aws_eip.nat_eip.public_ip
}

