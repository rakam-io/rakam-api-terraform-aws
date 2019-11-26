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
  default = 2
  type = "string"
}

variable "instance-ram-in-gb" {
  default = 8
  type = "string"
}

# ACM related

variable "certificate-domain" {
  type    = "string"
  default = "rakam-api._example.com"
}

variable "certificate-email" {
  type    = "string"
  default = "sysadmin@_example.com"
}

# RDS Related
variable "rakam-rds-username" {
  type    = "string"
  default = "rakam"
}
variable "rakam-rds-password" {
  type    = "string"
  default = "xxxxx"
}

# Rakam-API Related
variable "rakam-api-lock-key" {
  type    = "string"
  default = "xxxxx"
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
  default = "xxxx"
}

variable "rakam-collector-kinesis-shard-count" {
  type    = "string"
  default = 1
}