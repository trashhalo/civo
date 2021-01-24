variable "rss_secret_key_base" {}

module "rss" {
  source = "./modules/service"

  port               = 3000
  name               = "rss"
  app                = "Rss"
  image_pull_secrets = kubernetes_secret.docker.metadata.0.name
  image              = "ghcr.io/trashhalo/rss:latest"
  replicas           = 2

  env = {
    "RAILS_ENV"         = "production"
    "RAILS_MAX_THREADS" = "3"
  }

  secrets = {
    "SECRET_KEY_BASE" = var.rss_secret_key_base
  }
}