# Wait for EKS Endpoint to be available

provider "kubernetes" {
  cluster_ca_certificate = "${base64decode(aws_eks_cluster.rakam.certificate_authority.0.data)}"
  host                   =  "${aws_eks_cluster.rakam.endpoint}"
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["token", "-i", "${aws_eks_cluster.rakam.name}"]
    command     = "aws-iam-authenticator"
  }
}

## TODO wait for nodes
