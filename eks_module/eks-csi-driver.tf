#
# EKS Add-on : CSI Driver
#

data "tls_certificate" "terra" {
  url = aws_eks_cluster.terra.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "terra" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.terra.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.terra.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "AmazonEKS_EBS_CSI_DriverRole_emarket" {

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.terra.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.terra.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.terra.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "terra-csi" {
  assume_role_policy = data.aws_iam_policy_document.AmazonEKS_EBS_CSI_DriverRole_emarket.json
  name               = "AmazonEKS_EBS_CSI_DriverRole_emarket"
}

resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.terra-csi.name
}

#===========================================================
# Remove make EKS add-on module, because it takes 15 min.
# Use terraform code to create only the OIDC provider and IAM role, 
# and then create the CSI driver manually in the AWS console.
#===========================================================
#
# resource "aws_eks_addon" "addons" {
#   cluster_name      = aws_eks_cluster.terra.id
#   addon_name        = "aws-ebs-csi-driver"
#   service_account_role_arn = aws_iam_role.terra-csi.arn
#   depends_on = [ aws_eks_cluster.terra ]
# }

