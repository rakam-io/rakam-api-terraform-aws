locals {
  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.rakam.endpoint}
    certificate-authority-data: ${aws_eks_cluster.rakam.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster-name}"
KUBECONFIG
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
  sensitive   = true
}

# Required Kubernetes Configuration to Join Worker Nodes
locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.rakam-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
  sensitive   = true
}

# Kinesis stream name
output "kinesis_stream_name" {
  value = "${aws_kinesis_stream.rakamstream.name}"
}

# S3
output "s3_bucket_name" {
  value = "${aws_s3_bucket.rakams3.bucket_domain_name}"
}

# RDS
output "mysql_endpoint" {
  value = "${aws_db_instance.rakammysql.endpoint}"
}

# NLB
output "nlb-hostname" {
  description = "Set this CNAME pointing to your domain, verified via ACM"
  value = "${kubernetes_service.loadbalancer-nlb.load_balancer_ingress.0.hostname}"
}