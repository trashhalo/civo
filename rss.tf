variable "rss_secret_key_base" {}

module "rss" {
  source = "./modules/service"
  
  port     = 3000
  name     = "rss"
  app      = "Rss"
  host     = "rss.0qz.fun"
  image_pull_secrets = kubernetes_secret.docker.metadata.0.name
  image    = "ghcr.io/trashhalo/rss:latest"
  replicas = 5

  env = {
    "RAILS_ENV" = "production"
    "RAILS_MAX_THREADS" = "1"
  }

  secrets = {
    "SECRET_KEY_BASE" = var.rss_secret_key_base
  }
}