resource "aws_eks_cluster" "rakam" {
  name            = "${var.cluster-name}"
  role_arn        = "${aws_iam_role.rakam-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.rakam-cluster.id}"]
    subnet_ids         = "${aws_subnet.rakam.*.id}"
  }

  depends_on = [
    "aws_iam_role_policy_attachment.rakam-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.rakam-cluster-AmazonEKSServicePolicy",
  ]
}