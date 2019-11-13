resource "aws_iam_role" "rakam-node" {
  name = "terraform-eks-rakam-node"

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

resource "aws_iam_role_policy_attachment" "rakam-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.rakam-node.name}"
}

resource "aws_iam_role_policy_attachment" "rakam-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.rakam-node.name}"
}

resource "aws_iam_role_policy_attachment" "rakam-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.rakam-node.name}"
}

# To access kinesis
resource "aws_iam_role_policy_attachment" "rakam-node-AmazonKinesisFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
  role       = "${aws_iam_role.rakam-node.name}"
}

# To access S3
resource "aws_iam_role_policy_attachment" "rakam-node-AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "${aws_iam_role.rakam-node.name}"
}

# To create dynamo-DB
resource "aws_iam_role_policy_attachment" "rakam-node-AmazonDynamoDBFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = "${aws_iam_role.rakam-node.name}"
}

# To push kinesis log events to cloudwatch
resource "aws_iam_role_policy_attachment" "rakam-node-CloudWatchFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  role       = "${aws_iam_role.rakam-node.name}"
}

resource "aws_iam_instance_profile" "rakam-node" {
  name = "terraform-eks-rakam"
  role = "${aws_iam_role.rakam-node.name}"
}