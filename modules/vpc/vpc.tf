
#creates vpc
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name  = "${module.stack_vars.environment_name}-vpc"
  }
}


