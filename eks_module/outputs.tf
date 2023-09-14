#
# Outputs
#
locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH

apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles:
    - rolearn: ${aws_iam_role.terra-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG

***** Modify .kube/config file *****
=> 1. cluster config. 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${aws_eks_cluster.terra.certificate_authority[0].data}
    server: ${aws_eks_cluster.terra.endpoint}
  name: emarket 

=> 2. context config.
contexts:
- context:
    cluster: emarket
    user: emarket
  name: emarket

=> 3. users config.
users:
- name: emarket
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - --region
      - ${var.aws_region}
      - eks
      - get-token
      - --cluster-name
      - "${var.resource_prefix}-${var.cluster_name}"
      command: aws
KUBECONFIG
}

output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

output "kubeconfig" {
  value = local.kubeconfig
}

