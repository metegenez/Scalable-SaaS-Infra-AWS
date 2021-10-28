variable "acm_certificate" {
  type        = string
  description = "The arn of the certificate of the hosted zone of the Route 53 domain you want to use"
  default     = "arn:aws:acm:us-east-1:714130184239:certificate/84d3aa8d-9590-490e-91fd-06d3ca2ff3ff"
}

variable "load_balancer_sg" {}

variable "load_balancer_subnet_a" {}

variable "load_balancer_subnet_b" {}

variable "load_balancer_subnet_c" {}

variable "vpc" {}

