variable "civo_token" {}

terraform {
  required_providers {
    civo = {
      source  = "civo/civo"
      version = "0.9.23"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "1.3.2"
    }
  }
}

provider "civo" {
  token = var.civo_token
}

resource "civo_kubernetes_cluster" "my_cluster" {
  name              = "my-cluster"
  applications      = "Traefik"
  num_target_nodes  = 1
  target_nodes_size = "g2.small"
}

provider "kubernetes" {
  host             = civo_kubernetes_cluster.my_cluster.api_endpoint
  username         = yamldecode(civo_kubernetes_cluster.my_cluster.kubeconfig).users[0].user.username
  password         = yamldecode(civo_kubernetes_cluster.my_cluster.kubeconfig).users[0].user.password
  cluster_ca_certificate = base64decode(
    yamldecode(civo_kubernetes_cluster.my_cluster.kubeconfig).clusters[0].cluster.certificate-authority-data
  )
}

resource "kubernetes_secret" "docker" {
  metadata {
    name = "docker-cfg"
  }

  data = {
    ".dockerconfigjson" = file("/home/stephen/.docker/config.json")
  }

  type = "kubernetes.io/dockerconfigjson"
}

provider "helm" {
  kubernetes {
    host     = civo_kubernetes_cluster.my_cluster.api_endpoint
    username = yamldecode(civo_kubernetes_cluster.my_cluster.kubeconfig).users[0].user.username
    password = yamldecode(civo_kubernetes_cluster.my_cluster.kubeconfig).users[0].user.password

    cluster_ca_certificate = base64decode(
      yamldecode(civo_kubernetes_cluster.my_cluster.kubeconfig).clusters[0].cluster.certificate-authority-data
    )
  }
}