# Create a namespace for rakam-api
resource "kubernetes_namespace" "rakam-api" {
  metadata {
    name = "rakam-api"
  }
}

# Create a docker registry secret with GCP service-account provided by rakam
resource "kubernetes_secret" "gcr" {
  metadata {
    name      = "gcr"
    namespace = "${kubernetes_namespace.rakam-api.metadata.0.name}"
  }
  data = {
    ".dockerconfigjson" = jsonencode({
      "auths" : {
        "us.gcr.io" : {
          email    = "${var.certificate-email}"
          username = "_json_key"
          password = trimspace(file("${path.module}/license.json"))
          auth     = base64encode(join(":", ["_json_key", file("${path.module}/license.json")]))
        }
      }
    })
  }
  type = "kubernetes.io/dockerconfigjson"
}