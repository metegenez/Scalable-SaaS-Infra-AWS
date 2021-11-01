variable "acm_certificate" {
  type        = string
  description = "The arn of the certificate of the hosted zone of the Route 53 domain you want to use"
}

variable "load_balancer_sg" {}

variable "load_balancer_subnet_a" {}

variable "load_balancer_subnet_b" {}

variable "load_balancer_subnet_c" {}

variable "vpc" {}

