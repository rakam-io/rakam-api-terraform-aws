# Streamer to S3

resource "kubernetes_daemonset" "rakam-collector" {
    depends_on = ["kubernetes_namespace.rakam-api"]
    metadata {
        name = "rakam-collector"
        namespace = "${kubernetes_namespace.rakam-api.metadata.0.name}"
        labels = {
            app = "rakam-collector"
        }
    }

    spec {
        selector {
            match_labels = {
                app = "rakam-collector"
            }
        }
        strategy {
            type = "RollingUpdate"
        }
        template {
            metadata {
                name = "rakam-collector"
                labels = {
                    app = "rakam-collector"
                }
            }
            spec {
                container {
                    name = "rakam-collector"
                    image = "${var.rakam-collector-container-image}"
                    image_pull_policy = "Always"
                    env_from {
                        secret_ref {
                            name = "${kubernetes_secret.rakam-collector-secret.metadata.0.name}"
                        }
                    }

                    env_from {
                        config_map_ref {
                            name = "${kubernetes_config_map.rakam-collector-config.metadata.0.name}"
                        }
                    }
                    command = ["java"]
                    args = ["-Denv=RAKAM_CONFIG",
                            "-XX:+UnlockExperimentalVMOptions",
                            "-XX:+UseCGroupMemoryLimitForHeap",
                            "-XX:OnOutOfMemoryError=kill -9 %p",
                            "-jar", "/compiled/target/rakam-data-collector.jar",
                            "/dev/null"] // instead of config.properties
                }
                image_pull_secrets {
                    name = "${kubernetes_secret.gcr.metadata.0.name}"
                }
                restart_policy = "Always"
                # For a Pod to be given a QoS class of BestEffort, the Containers in the Pod must not have any memory or CPU limits or requests.
                # qos_class = "BestEffort"
            }
        }
    }
}

# Config maps & secrets
resource "kubernetes_config_map" "rakam-collector-config" {
  metadata {
    name = "rakamcollectorconfig"
    namespace = "${kubernetes_namespace.rakam-api.metadata.0.name}"
  }

  data = { // TODO
    RAKAM_CONFIG_TARGET = "s3"
    RAKAM_CONFIG_TARGET_AWS_REGION = "${var.aws_region}"
    RAKAM_CONFIG_TARGET_AWS_S3__BUCKET =  "${aws_s3_bucket.rakams3.bucket}"
    RAKAM_CONFIG_STREAM_SOURCE = "kinesis"
    RAKAM_CONFIG_KINESIS_STREAM = "${aws_kinesis_stream.rakamstream.name}"
    RAKAM_CONFIG_LICENSE_KEYNAME = "${var.rakam-collector-license-key-name}"

    RAKAM_CONFIG_METADATA_STORE_JDBC_URL     = "jdbc:mysql://${aws_db_instance.rakammysql.endpoint}/${aws_db_instance.rakammysql.name}?useSSL=false"
    RAKAM_CONFIG_METADATA_STORE_JDBC_USERNAME     = "${var.rakam-rds-username}"
    RAKAM_CONFIG_METADATA_STORE_JDBC_MAX__CONNECTION = "5"
  }
}

# Create secrets
resource "kubernetes_secret" "rakam-collector-secret" {
  metadata {
    name = "rakamcollectorsecret"
    namespace = "${kubernetes_namespace.rakam-api.metadata.0.name}"
  }

  data = {
    RAKAM_CONFIG_METADATA_STORE_JDBC_PASSWORD     = "${var.rakam-rds-password}"
    RAKAM_CONFIG_LICENSE_SERVICE__ACCOUNT__JSON   = trimspace(file("${path.module}/gcr.json"))
  }
}