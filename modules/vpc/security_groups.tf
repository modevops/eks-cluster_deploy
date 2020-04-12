resource "aws_security_group" "public-sg" {
  count = var.create_security_groups ? 1 : 0

  name = "Public"
  description = "allow all traffic to firewall"
  vpc_id = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.workstation-external-cidr]
  }

  tags =  { "Name" = format("%s-PublicSecurityGroup", module.stack_vars.environment_name )
}

}

resource "aws_security_group" "internal-sg" {
  count = var.create_security_groups ? 1 : 0

  name = "Internal"
  description = "Allow traffic to firewall internal interfaces"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      var.cidr_block]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    "Name" = format("%s-InternalSecurityGroup", module.stack_vars.environment_name)
  }
}