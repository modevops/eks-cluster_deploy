// ----------------------------------------------------------------------------
// Update the kube configuration after the cluster has been created so we can
// connect to it and create the K8s resources
// ----------------------------------------------------------------------------
resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.stack_vars.cluster_name}"
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [
    aws_eks_cluster.eks_cluster, aws_autoscaling_group.eks_nodes
  ]
}

# saves output to local.config-map-aws-auth to aws_auth to files/aws-auth.yaml
resource "local_file" "aws_auth" {
  content  = local.config-map-aws-auth
  filename = "${path.root}/files/aws-auth.yaml"

  depends_on = [
      aws_eks_cluster.eks_cluster, aws_autoscaling_group.eks_nodes, null_resource.kubeconfig
    ]

}

## uses kubectl to apply the aws_auth.yaml  the AWS IAM Authenticator configuration map
resource "null_resource" "aws_auth" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.root}/files/aws-auth.yaml"
  }

  depends_on = [
    aws_eks_cluster.eks_cluster, aws_autoscaling_group.eks_nodes, local_file.aws_auth, null_resource.kubeconfig
  ]
}

## installs calico daemonset
resource "null_resource" "install_calico" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.5/config/v1.5/calico.yaml"
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_autoscaling_group.eks_nodes,
    local_file.aws_auth,
    null_resource.kubeconfig,
    null_resource.aws_auth
  ]

}