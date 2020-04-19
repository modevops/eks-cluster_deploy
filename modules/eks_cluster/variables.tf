module "global_vars" { source = "../global_vars" }
module "stack_vars" { source = "../stack" }


locals {
  worker_nodes_names  =  "eks-${module.stack_vars.environment_name}-${module.stack_vars.project_name}-nodes"
}

variable "key_name" {
  default = "modevops"
}
variable "aws_auth" {
  default     = ""
  description = "Grant additional AWS users or roles the ability to interact with the EKS cluster."
}

variable "enable_kubectl" {
  default     = true
  description = "When enabled, it will merge the cluster's configuration with the one located in ~/.kube/config."
}

variable "enable_dashboard" {
  default     = false
  description = "When enabled, it will install the Kubernetes Dashboard."
}

variable "enable_calico" {
  default     = false
  description = "When enabled, it will install Calico for network policy support."
}

variable "enable_kube2iam" {
  default     = false
  description = "When enabled, it will install Kube2IAM to support assigning IAM roles to Pods."
}


variable "public_key_path" {
  default   = "./tform.pub"
}

variable "public_subnets" {}
variable "public_sg_id" {}
variable "private_subnets" {}
variable "internal_sg_id" {}
variable "vpc_id" {}
variable "cidr_block" {}
variable public_subnets_ids {}
variable "write_kubeconfig" {
  description = "Whether to write a Kubectl config file containing the cluster configuration. Saved to `config_output_path`."
  type        = bool
  default     = true
}

variable "config_output_path" {
  description = "Where to save the Kubectl config file (if `write_kubeconfig = true`). Assumed to be a directory if the value ends with a forward slash `/`."
  type        = string
  default     = "./"
}
