# eks-cluster_deploy
# EKS CLuster Deploy
##Purpose
This terraform scripts does the following:
  1. Creates a AWS VPC with a Internet Gateway, Nat Gateway, public and private subnets.
  2. Creates EKS cluster using Spot Instances and Nodes with a autoscaling group.
  3. Uses a Null Resource and a commandline action to update local kubeconfig.
  4. Exports to file config-map-aws-auth.yml to a file  and uses kubectl to apply the configmap.
  5. Lastly uses kubectl to download and apply Calico CNI.
  
See https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html for full guide

## Requirements
AWS Account
Terraform
kubectl
heptio awws-iam-authenticator


## Files 
```
├── README.md
├── files
├── main.tf
├── modules
│   ├── eks_cluster
│   │   ├── data.tf
│   │   ├── eks_cluster.tf
│   │   ├── eks_cluster_iam.tf
│   │   ├── files
│   │   ├── local_exec_auth_eks.tf
│   │   ├── output.tf
│   │   ├── security_groups.tf
│   │   ├── variables.tf
│   │   ├── worker_nodes.tf
│   │   └── worker_nodes_iam.tf
│   ├── global_vars
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── stack
│   │   ├── output.tf
│   │   └── variables.tf
│   └── vpc
│       ├── data.tf
│       ├── internet_gateway.tf
│       ├── locals.tf
│       ├── nat_gateway.tf
│       ├── networking.tf
│       ├── outputs.tf
│       ├── security_groups.tf
│       ├── variables.tf
│       ├── vpc.tf
│       └── workstation-external-ip.tf
├── provider.tf
└── variables.tf

```
## Module setup example
```

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

Also depending on how many nodes are being setup you may need to edit modules/eks_cluster.tf and modules/worker_noodes.tf
update 

 subnet_ids = [var.public_subnets[0].id, var.public_subnets[1].id, var.public_subnets[2].id]
 
 and 
 
 vpc_zone_identifier = [var.public_subnets[0].id, var.public_subnets[1].id, var.public_subnets[2].id]

```
## Terraform apply
```
terraform init
terraform apply
```

## Download kubectl
```
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin
```

## Download the aws-iam-authenticator
```
wget https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64
chmod +x heptio-authenticator-aws_0.3.0_linux_amd64
sudo mv heptio-authenticator-aws_0.3.0_linux_amd64 /usr/local/bin/heptio-authenticator-aws
```

## Modify providers.tf

Choose your region. EKS is not available in every region, use the Region Table to check whether your region is supported: https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/

Make changes in providers.tf accordingly (region, optionally profile)



## Terraform apply
```
terraform init
terraform apply
```

## Configure kubectl
```
terraform output kubeconfig # save output in ~/.kube/config
aws eks --region <region> update-kubeconfig --name terraform-eks-demo
```

## Configure config-map-auth-aws
```
terraform output config-map-aws-auth # save output in config-map-aws-auth.yaml
kubectl apply -f config-map-aws-auth.yaml
```

## See nodes coming up
```
kubectl get nodes
```

## Destroy
Make sure all the resources created by Kubernetes are removed (LoadBalancers, Security groups), and issue:
```
terraform destroy
```


## Known Issues
1. Found issue when I had the spot instances price to low. (Nodes will not deploy if prices is to low. You can set worker_nodes.tf)

2. Nodes will not talk to Masters until you deploy the confimap config-map-auth-aws (This why I added local_exec_auth_eks.tf which updates kubeconfig and uses kubectl to apply config-map-aws-auth.yaml)
