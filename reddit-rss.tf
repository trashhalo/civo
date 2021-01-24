
variable "reddit_rss_sentry_dsn" {}

module "reddit_rss" {
  source = "./modules/service"

  port               = 8080
  name               = "reddit-rss"
  app                = "RedditRss"
  image_pull_secrets = kubernetes_secret.docker.metadata.0.name
  image              = "ghcr.io/trashhalo/reddit-rss:latest"
  replicas           = 2

  secrets = {
    "SENTRY_DSN" = var.reddit_rss_sentry_dsn
  }
}