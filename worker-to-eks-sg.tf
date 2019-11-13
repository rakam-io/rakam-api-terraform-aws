resource "aws_security_group_rule" "rakam-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.rakam-cluster.id}"
  source_security_group_id = "${aws_security_group.rakam-node.id}"
  to_port                  = 443
  type                     = "ingress"
}