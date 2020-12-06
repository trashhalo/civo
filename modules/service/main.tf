resource "kubernetes_service" "service" {
  metadata {
    name = "${var.name}-service"
  }

  spec {
    selector = {
      app = var.app
    }
    session_affinity = "ClientIP"
    port {
      port        = var.port
      target_port = var.port
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_secret" "secret" {
  metadata {
    name = "${var.name}-secret"
  }

  data = var.secrets
}

resource "kubernetes_deployment" "deploy" {
  metadata {
    name = "${var.name}-deploy"
    labels = {
      app = var.app
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app
      }
    }

    template {
      metadata {
        name = "${var.name}-pod"
        labels = {
          app = var.app
        }
      }

      spec {
        image_pull_secrets {
          name = var.image_pull_secrets
        }

        container {
          image = var.image
          name  = var.name

          liveness_probe {
            http_get {
              path = "/info/ping"
              port = var.port
            }
            initial_delay_seconds = 3
            period_seconds        = 3
          }

          readiness_probe {
            http_get {
              path = "/info/ping"
              port = var.port
            }
            initial_delay_seconds = 3
            period_seconds        = 3
          }

          dynamic "env" {
            for_each = var.env

            content {
              name  = env.key
              value = env.value
            }
          }

          dynamic "env" {
            for_each = var.secrets
            content {
              name = env.key

              value_from {
                secret_key_ref {
                  name = kubernetes_secret.secret.metadata.0.name
                  key  = env.key
                }
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress" "ingress" {
  metadata {
    name = var.name

    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
    }
  }

  spec {
    rule {
      host = var.host

      http {
        path {
          path = "/"

          backend {
            service_name = kubernetes_service.service.metadata.0.name
            service_port = var.port
          }
        }
      }
    }
  }
}