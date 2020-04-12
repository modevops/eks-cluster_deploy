
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
  {
    "Name" = format("%s-IGW", module.stack_vars.environment_name)
  }
  )
}