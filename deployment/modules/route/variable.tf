variable "hosted_zone_id" {
  type        = string
  description = "The id of the hosted zone of the Route 53 domain you want to use"
}

variable "elb" {

}
variable "backend_sub_domain_prefix" {}
variable "domain_name" {}
