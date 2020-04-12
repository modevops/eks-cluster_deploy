# NAT gateways need public IPs
resource "aws_eip" "nat_gateway_elastic_ips" {
  count = length(var.private_subnet_cidrs)
  vpc   = true

}

resource "aws_nat_gateway" "nat_gateways" {
  count = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  allocation_id = "${aws_eip.nat_gateway_elastic_ips[count.index].id}"
  depends_on    = ["aws_internet_gateway.igw",aws_subnet.private_subnets, aws_subnet.public_subnets] # Declaring dependency, as the dependency graph doesn't explicitly create one


}