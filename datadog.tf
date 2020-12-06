variable "datadog_apikey" {}

resource "helm_release" "datadog" {
  name  = "datadog"
  chart = "datadog/datadog"

  values = [file("datadog.yaml")]

  set {
    name  = "datadog.site"
    value = "datadoghq.com"
  }

  set {
    name  = "datadog.apiKey"
    value = var.datadog_apikey
  }
}