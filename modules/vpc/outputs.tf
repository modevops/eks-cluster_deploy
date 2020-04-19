output "vpc_arn" { value = "${aws_vpc.main.arn}" }

output "vpc_id" {
  value = aws_vpc.main.id
}

output "igw_id" {
  value = concat(aws_internet_gateway.igw.*.id, [""])[0]
}



output "public_rt_id" {
  value = concat(aws_route_table.public_route_table.*.id, [""])[0]
}

output "private_subnets" {
  value = aws_subnet.private_subnets
}

output "public_sg_id" {
  value = concat(aws_security_group.public-sg.*.id, [""])[0]
}


output "internal_sg_id" {
  value = concat(aws_security_group.internal-sg.*.id, [""])[0]
}


output "workstation_cidr" {
  value = local.workstation-external-cidr
}

output "cidr_block" {
  value = var.cidr_block
}

output "private_subnet_ids" {
  value = [aws_subnet.private_subnets[*].id]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public_subnets
}

output "public_subnets_ids" {
  value = aws_subnet.public_subnets.*.id
}

output "cluster_name" {
  value = "var.cluster_name"
}