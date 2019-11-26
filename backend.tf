# Save TF-state files here
# https://www.terraform.io/docs/backends/types/s3.html
terraform {
  backend "s3" {
    bucket = "terraform-rakam"
    key    = "rakam-api-tf/terraform.tfstate"
    region = "eu-west-1"
  }
}