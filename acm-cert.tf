# Create a new load balancer
resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.certificate-domain}"
  validation_method = "DNS"

  tags = {
    Name = "terraform-eks-rakam"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "cert-arn" {
    value = aws_acm_certificate.cert.arn
}

output "cert-dns" {
    value = aws_acm_certificate.cert.domain_validation_options
}