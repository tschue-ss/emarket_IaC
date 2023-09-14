#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "terra-node" {
  name = "${var.resource_prefix}-eks-node-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "terra-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.terra-node.name
}

resource "aws_iam_role_policy_attachment" "terra-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.terra-node.name
}

resource "aws_iam_role_policy_attachment" "terra-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.terra-node.name
}

resource "aws_eks_node_group" "terra" {
  cluster_name    = aws_eks_cluster.terra.name
  node_group_name = "${var.resource_prefix}-${var.cluster_node_name}"
  node_role_arn   = aws_iam_role.terra-node.arn
  subnet_ids      = [var.subnet_id1, var.subnet_id2]
  instance_types  = var.node_type

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.terra-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.terra-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.terra-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
