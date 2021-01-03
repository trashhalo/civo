variable "fediverse_aws_access_key_id" {}
variable "fediverse_aws_secret_access_key" {}
variable "fediverse_aws_default_region" {}

resource "kubernetes_secret" "fediverse" {
  metadata {
    name = "fediverse-secret"
  }

  data = {
    "AWS_ACCESS_KEY_ID" = var.fediverse_aws_access_key_id
    "AWS_SECRET_ACCESS_KEY" = var.fediverse_aws_secret_access_key
  }
}

resource "kubernetes_cron_job" "fediverse" {
  metadata {
    name = "fediverse-cron-job"
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = "0 * * * *"
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
              name  = "mastadon-explorer"
              image = "ghcr.io/trashhalo/mastodon-explorer"

              env {
                name  = "AWS_DEFAULT_REGION"
                value = var.fediverse_aws_default_region
              }

              env {
                name = "AWS_ACCESS_KEY_ID"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.fediverse.metadata.0.name
                    key  = "AWS_ACCESS_KEY_ID"
                  }
                }
              }

              env {
                name = "AWS_SECRET_ACCESS_KEY"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.fediverse.metadata.0.name
                    key  = "AWS_SECRET_ACCESS_KEY"
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