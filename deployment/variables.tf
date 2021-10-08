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
