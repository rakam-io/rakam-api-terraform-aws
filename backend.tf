# Save TF-state files here
# https://www.terraform.io/docs/backends/types/s3.html
terraform {
  backend "s3" {
    bucket = "tf-state-appwise"
    key    = "rakam-api-tf/"
    region = "eu-west-1"
  }
}