resource "kubernetes_service" "s0qz_fun_service" {
  metadata {
    name = "s0qz-fun-service"
  }

  spec {
    selector = {
      app = "S0qzFun"
    }
    session_affinity = "None"
    port {
      port        = 80
      target_port = kubernetes_deployment.s0qz_fun_deploy.spec.0.template.0.spec.0.container.0.port.0.container_port
      protocol = "TCP"
    }
  }
}

resource "kubernetes_deployment" "s0qz_fun_deploy" {
  metadata {
    name = "s0qz-fun-deploy"
    labels = {
      app = "S0qzFun"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "S0qzFun"
      }
    }

    template {
      metadata {
        name = "s0qz-fun-pod"
        labels = {
          app = "S0qzFun"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_secret.docker.metadata.0.name
        }

        container {
          image = "ghcr.io/trashhalo/0qz-fun:latest"
          name  = "s0qz-fun"

          port {
            name           = "http"
            container_port = 80
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 3
            period_seconds        = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}