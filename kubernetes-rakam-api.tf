resource "kubernetes_daemonset" "rakam-api" {
  depends_on = ["kubernetes_namespace.rakam-api"]
  metadata {
    name      = "rakam-api"
    namespace = "${kubernetes_namespace.rakam-api.metadata.0.name}"
    labels = {
      app = "rakam-api"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "rakam-api"
      }
    }
    strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        name = "rakam-api"
        labels = {
          app = "rakam-api"
        }
      }
      spec {
        container {
          name              = "rakam-api"
          image             = "${var.rakam-api-container-image}"
          image_pull_policy = "Always"
          liveness_probe {
            http_get {
              path   = "/"
              port   = "9999"
              scheme = "HTTP"
            }

            initial_delay_seconds = 20
            timeout_seconds       = 5
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path   = "/"
              port   = "9999"
              scheme = "HTTP"
            }

            initial_delay_seconds = 20
            timeout_seconds       = 5
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 5
          }
          args = ["custom"] # Don't use default rakam-api flags.
          env {
            name  = "JAVA_OPTS"
            value = "-XX:+UnlockExperimentalVMOptions -XX:+ExitOnOutOfMemoryError -XX:MinRAMPercentage=50.0 -XX:MaxRAMPercentage=80.0"
          }
          env_from {
            secret_ref {
              name = "${kubernetes_secret.rakam-api-secret.metadata.0.name}"
            }
          }

          env_from {
            config_map_ref {
              name = "${kubernetes_config_map.rakam-api-config.metadata.0.name}"
            }
          }
          resources {
            limits {
              memory = "${format("%.2fGi", var.instance-ram-in-gb * 0.45)}" // Limit maximum allocatable memory to half
            }

            requests {
              cpu    = "${format("%.2f", var.instance-cpu-count * 0.7)}" // Request the 70% of total CPU on the node
              memory = "${format("%.2fGi", var.instance-ram-in-gb * 0.25)}" // Request the 1/4'th of uncompressable memory. 
            }
          }
        }
        image_pull_secrets {
          name = "${kubernetes_secret.gcr.metadata.0.name}"
        }
        restart_policy = "Always"
      }
    }
  }
}

# Expose rakam-api over external L4 loadbalancer
resource "kubernetes_service" "loadbalancer-nlb" {
  depends_on = ["kubernetes_daemonset.rakam-api"]
  metadata {
    name      = "rakamapi-loadbalancer-nlb"
    namespace = "${kubernetes_namespace.rakam-api.metadata.0.name}"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      # ssl-cert is added on kubernetes 1.15. Expected delivery to EKS is ~Dec'19.
      # While EKS supports 1.14 time of this release. 443 port has to be changed to TLS and arn to acm cert arn.
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"                = "${aws_acm_certificate.cert.arn}"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"        = "http"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"               = "443"
      "service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout" = "60"
    }
  }

  spec {
    type = "LoadBalancer"
    port {
      name        = "https"
      port        = 443
      target_port = 9999
    }

    port {
      name        = "http"
      port        = 80
      target_port = 9999
    }

    selector = {
      app = "${kubernetes_daemonset.rakam-api.metadata.0.labels.app}"
    }
  }
}

# Create config maps and secrets
resource "kubernetes_config_map" "rakam-api-config" {
  metadata {
    name      = "rakamapiconfig"
    namespace = "${kubernetes_namespace.rakam-api.metadata.0.name}"
  }

  data = {
    RAKAM_CONFIG_METADATA_STORE_JDBC_URL             = "jdbc:mysql://${aws_db_instance.rakammysql.endpoint}/${aws_db_instance.rakammysql.name}?useSSL=false"
    RAKAM_CONFIG_METADATA_STORE_JDBC_USERNAME        = "${var.rakam-rds-username}"
    RAKAM_CONFIG_METADATA_STORE_JDBC_MAX__CONNECTION = "5"
    RAKAM_CONFIG_EVENT_STORE                         = "kinesis"
    RAKAM_CONFIG_EVENT_STORE_KINESIS_STREAM          = "${aws_kinesis_stream.rakamstream.name}"
    RAKAM_CONFIG_PLUGIN_USER_ENABLED                 = "false"
    RAKAM_CONFIG_AWS_REGION                          = "${var.aws_region}"
  }
}

resource "kubernetes_secret" "rakam-api-secret" {
  metadata {
    name      = "rakamapisecret"
    namespace = "${kubernetes_namespace.rakam-api.metadata.0.name}"
  }

  data = {
    RAKAM_CONFIG_LOCK__KEY                      = "${var.rakam-api-lock-key}"
    RAKAM_CONFIG_METADATA_STORE_JDBC_PASSWORD   = "${var.rakam-rds-password}"
    RAKAM_CONFIG_LICENSE_SERVICE__ACCOUNT__JSON = trimspace(file("${path.module}/license.json"))
  }
}