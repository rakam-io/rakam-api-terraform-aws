data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.rakam.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}


# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_region" "current" {}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We implement a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  rakam-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.rakam.endpoint}' --b64-cluster-ca '${aws_eks_cluster.rakam.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

resource "aws_launch_configuration" "rakam" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.rakam-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.instance-type}"
  name_prefix                 = "terraform-eks-worker"
  security_groups             = ["${aws_security_group.rakam-node.id}"]
  user_data_base64            = "${base64encode(local.rakam-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

# AutoScaling Group that actually launches EC2 instances based on the AutoScaling Launch Configuration.
resource "aws_autoscaling_group" "rakam" {
  desired_capacity     = "${var.instance-capacity}"
  launch_configuration = "${aws_launch_configuration.rakam.id}"
  max_size             = "${var.instance-capacity-max}"
  min_size             = "${var.instance-capacity-min}"
  name                 = "terraform-eks-workers"
  vpc_zone_identifier  = "${aws_subnet.rakam.*.id}"

  tag {
    key                 = "Name"
    value               = "terraform-eks-workers"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
}