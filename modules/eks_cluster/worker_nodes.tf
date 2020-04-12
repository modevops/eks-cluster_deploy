data "aws_ami" "eks_workers" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.eks_cluster.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks_cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks_cluster.certificate_authority.0.data}' '${local.cluster_name}'
USERDATA
}




resource "aws_launch_configuration" "eks_nodes" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.worker_nodes.name
  image_id                    = data.aws_ami.eks_workers.id
  instance_type               = "m4.large"
  name_prefix                 = "${local.worker_nodes_names}"
  security_groups             = [aws_security_group.eks-workers.id,var.internal_sg_id]
  spot_price                  = "0.06"
  key_name                    =  var.key_name
  user_data_base64            = "${base64encode(local.eks-node-userdata)}"
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_nodes_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_nodes_AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_autoscaling_group" "eks_nodes" {
  desired_capacity = 3
  launch_configuration = aws_launch_configuration.eks_nodes.id
  max_size = module.stack_vars.cluster_conf.count.max
  min_size = module.stack_vars.cluster_conf.count.max
  name = local.worker_nodes_names

  vpc_zone_identifier =  [var.private_subnets[0].id, var.private_subnets[1].id, var.private_subnets[2].id]

  tag {
    key = "Name"
    value = ""
    propagate_at_launch = true
  }

  tag {
    key = "kubernetes.io/cluster/${local.cluster_name}"
    value = "owned"
    propagate_at_launch = true
  }
}