variable "region" {
  default     = "us-east-1"
  type        = string
  description = "The region you want to deploy the infrastructure in"
}

variable "hosted_zone_id" {
  type        = string
  description = "The id of the hosted zone of the Route 53 domain you want to use"
  default     = "Z08633611HETQYXOEWMJ4"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "github_personal_token" {
  description = "Personal access tokens function like ordinary OAuth access tokens. They can be used instead of a password for Git over HTTPS, or can be used to authenticate to the API over Basic Authentication."
  type        = string
  sensitive   = true
}

variable "current_deployment_state" {
  type        = string
  description = "Since Blue/Green Deployment messes with the state, we use this as a workaround. It can be A or B. Blue and green roles interchangable between target groups."
}
