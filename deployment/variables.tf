variable "region" { 
  type        = string
  description = "The region you want to deploy the infrastructure in"
}

variable "hosted_zone_id" {
  type        = string
  description = "The id of the hosted zone of the Route 53 domain you want to use"
}

variable "aws_secret_manager_secret_arn"{
  type = string
  description = "Use Secrets Manager to store, rotate, monitor, and control access to secrets such as database credentials, API keys, and OAuth tokens."
}


variable "branch" {
  type = map(string)
  description = "Mapping Terraform Workspaces into Github Branchs"
}

variable "backend_sub_domain_prefix" {}
variable "frontend_sub_domain_prefix" {}
variable "domain_name" {}
variable "github_repository" {}
variable "acm_certificate" {}