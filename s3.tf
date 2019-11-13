resource "aws_s3_bucket" "rakams3" {
  bucket_prefix = "rakam-"
  acl    = "private"

  tags = {
    Name = "terraform-s3-rakam"
  }
}