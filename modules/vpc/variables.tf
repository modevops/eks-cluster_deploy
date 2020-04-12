module "stack_vars" { source = "../stack" }
module "global_vars" { source = "../global_vars" }


variable "cidr_block" {
  description = "List of VPC Security Groups"
  type = string
  default = "10.0.0.0/16"
}


variable "availability_zones" {
  description = "List of availability zones to create subnets in."
  type        = list(string)
  default     = []
}

variable "create_public_subnets" {
  description = "Controls if public subnets should be created."
  type        = bool
  default     = true
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for management subnets."
  type        = list(string)
  default     = []
}

variable "create_private_subnets" {
  description = "Controls if private subnets should be created."
  type        = bool
  default     = true
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for management subnets."
  type        = list(string)
  default     = []
}


variable "create_security_groups" {
  description = "Controls if security groups should be created."
  type        = bool
  default     = true
}

variable "private_subnets" {}