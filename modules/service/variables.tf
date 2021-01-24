variable "name" {
  type = string
}

variable "app" {
  type = string
}

variable "port" {
  type    = number
  default = 8080
}

variable "secrets" {
  type    = map(any)
  default = {}
}

variable "env" {
  type    = map(any)
  default = {}
}

variable "image" {
  type = string
}

variable "replicas" {
  type = number
}

variable "image_pull_secrets" {
  type = string
}