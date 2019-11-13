# Configure the AWS Provider
provider "aws" {
  profile = "default"
  region  = "${var.aws_region}"
}