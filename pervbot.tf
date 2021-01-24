variable "pervbot_twitter_consumer_key" {}
variable "pervbot_twitter_consumer_secret" {}
variable "pervbot_twitter_access_token" {}
variable "pervbot_twitter_token_secret" {}

resource "kubernetes_secret" "pervbot" {
  metadata {
    name = "pervbot-secret"
  }

  data = {
    "twitter_consumer_key"    = var.pervbot_twitter_consumer_key
    "twitter_consumer_secret" = var.pervbot_twitter_consumer_secret
    "twitter_access_token"    = var.pervbot_twitter_access_token
    "twitter_token_secret"    = var.pervbot_twitter_token_secret
  }
}

resource "kubernetes_cron_job" "pervbot" {
  metadata {
    name = "pervbot-cron-job"
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = "0 13,19 * * *"
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        template {
          metadata {}
          spec {
            image_pull_secrets {
              name = kubernetes_secret.docker.metadata.0.name
            }

            container {
              name  = "pervbot"
              image = "ghcr.io/trashhalo/pervbot:latest"

              env {
                name = "twitter_consumer_key"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.pervbot.metadata.0.name
                    key  = "twitter_consumer_key"
                  }
                }
              }

              env {
                name = "twitter_consumer_secret"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.pervbot.metadata.0.name
                    key  = "twitter_consumer_secret"
                  }
                }
              }

              env {
                name = "twitter_access_token"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.pervbot.metadata.0.name
                    key  = "twitter_access_token"
                  }
                }
              }

              env {
                name = "twitter_token_secret"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.pervbot.metadata.0.name
                    key  = "twitter_token_secret"
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}