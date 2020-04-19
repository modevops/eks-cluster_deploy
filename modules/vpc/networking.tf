

resource "aws_subnet" "public_subnets" {
  count = var.create_public_subnets ? length(var.public_subnet_cidrs) : 0

  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones,  count.index % length(var.availability_zones))

  tags = merge(

  {
    "Name" = format("%s-Public-%s", module.stack_vars.environment_name,  element(var.availability_zones, count.index))
    KubernetesCluster        = "${module.stack_vars.environment_name}-ingress"
    "kubernetes.io/role/elb" = "1"

  },
   {
    key = "kubernetes.io/cluster/${module.stack_vars.cluster_name}"
    value = "shared"
    propagate_at_launch = true
  },

  {
    KubernetesCluster        = module.stack_vars.cluster_name
    "kubernetes.io/role/elb" = "1"
  }
  )
}


resource "aws_subnet" "private_subnets" {
  count = var.create_private_subnets ? length(var.private_subnet_cidrs) : 0

  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs,  count.index)
  availability_zone = element(var.availability_zones,  count.index  % length(var.availability_zones))

  tags = merge(

  {
    "Name" = format("%s-Public-%s", module.stack_vars.environment_name,  element(var.availability_zones, count.index))

  },
  {
    key = "kubernetes.io/cluster/${module.stack_vars.cluster_name}"
    value = "shared"
    propagate_at_launch = true
  }
  )
}

resource "aws_route_table" "public_route_table" {
  vpc_id            = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { "Name" = format("%s-PublicRouteTable", module.stack_vars.environment_name) }
}

resource "aws_route_table_association" "public_rt_association" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id            = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags ={ "Name" = format("%s-PublicRouteTable", module.stack_vars.environment_name) }
}

resource "aws_route_table_association" "private_rt_association" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}