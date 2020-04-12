


module "vpc" {
  source = "./modules/vpc"
  cidr_block           = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b","us-east-1c"]
  public_subnet_cidrs  = [ "10.0.10.0/24", "10.0.110.0/24", "10.0.120.0/24" ]
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.5.0/24", "10.0.15.0/24" ]
  private_subnets = module.vpc.private_subnets

}

module "eks_cluster" {
  source = "./modules/eks_cluster"
  vpc_id = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  internal_sg_id = module.vpc.internal_sg_id
  cidr_block = module.vpc.cidr_block
  public_sg_id = module.vpc.public_sg_id
  public_subnets_ids = module.vpc.public_subnets_ids

}