#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#
resource "aws_eks_cluster" "eks_cluster" {
  name = module.stack_vars.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {

    security_group_ids = [
      aws_security_group.eks-cluster.id,
      aws_security_group.eks-workers.id,
      var.public_sg_id
    ]
    subnet_ids = [var.private_subnets[0].id, var.private_subnets[1].id, var.private_subnets[2].id]
  }
  depends_on = [
    # These aren't explicitly part of the dependency tree TF generates
    aws_iam_role_policy_attachment.eks_cluster_role_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_role_AmazonEKSServicePolicy,

  ]
}