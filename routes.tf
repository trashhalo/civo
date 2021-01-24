resource "kubernetes_ingress" "routes" {
  metadata {
    name = "routes"

    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
    }
  }

  spec {
    rule {
      host = "0qz.fun"

      http {
        path {
          path = "/"

          backend {
            service_name = "s0qz-fun-service"
            service_port = 80
          }
        }
      }
    }

    rule {
      host = "rss.0qz.fun"

      http {
        path {
          path = "/"

          backend {
            service_name = module.rss.service_name
            service_port = module.rss.service_port
          }
        }
      }
    }

    rule {
      host = "reddit.0qz.fun"

      http {
        path {
          path = "/"

          backend {
            service_name = module.reddit_rss.service_name
            service_port = module.reddit_rss.service_port
          }
        }
      }
    }    
  }
}