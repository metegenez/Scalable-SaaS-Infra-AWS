variable "acm_certificate" {
  type        = string
  description = "The arn of the certificate of the hosted zone of the Route 53 domain you want to use"
  default     = "arn:aws:acm:us-east-1:714130184239:certificate/6bcf0578-892d-441b-9eee-1be9ad1fd9d7"
}

variable "load_balancer_sg" {}

variable "load_balancer_subnet_a" {}

variable "load_balancer_subnet_b" {}

variable "load_balancer_subnet_c" {}

variable "vpc" {}

variable "current_deployment_state" {

}

