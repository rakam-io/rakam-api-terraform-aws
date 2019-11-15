# Globals
variable "aws_region" {
  description = "Region for Rakam stack deployment"
  default     = "eu-west-1"
}
variable "cluster-name" {
  default = "terraform-eks-rakam"
  type    = "string"
}

# Autoscaling related
variable "instance-type" {
  default = "t3a.large"
  type    = "string"
}
variable "instance-capacity" {
  default = 2
  type    = "string"
}

variable "instance-capacity-min" {
  default = 1
  type    = "string"
}

variable "instance-capacity-max" {
  default = 2
  type    = "string"
}

variable "instance-cpu-count" {
  default = 4
  type = "string"
}

variable "instance-ram-in-gb" {
  default = 16
  type = "string"
}

# ACM related

variable "certificate-domain" {
  type    = "string"
  default = "aptoidelb.rakam.io"
}

variable "certificate-email" {
  type    = "string"
  default = "youraccount@rakam-api.iam.gserviceaccount.com"
}

# RDS Related
variable "rakam-rds-username" {
  type    = "string"
  default = "username"
}
variable "rakam-rds-password" {
  type    = "string"
  default = "password"
}

# Rakam-API Related
variable "rakam-api-lock-key" {
  type    = "string"
  default = "4sdJIqLsZXtHv8cdctGJHe"
}

variable "rakam-api-container-image" {
  type    = "string"
  default = "us.gcr.io/rakam-bi-bundle/rakam-api:latest"
}

# Rakam-Collector Related
variable "rakam-collector-container-image" {
  type    = "string"
  default = "us.gcr.io/rakam-bi-bundle/rakam-collector:latest"
}

variable "rakam-collector-license-key-name" {
  type    = "string"
  default = "aptoide"
}

variable "rakam-collector-kinesis-shard-count" {
  type    = "string"
  default = 1
}
