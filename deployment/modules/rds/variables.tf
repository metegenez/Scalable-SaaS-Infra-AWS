variable "ecs_subnet_a" {}

variable "ecs_subnet_b" {}

variable "ecs_subnet_c" {}

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

# variable "db_instance_class" {
#   value = lookup(var.db_instance_class_map, terraform.workspace, "db.t3.micro")
# }

variable "vpc" {}

# variable "db_instance_class_map" {
#   type = map(string)

#   default = {
#     dev     = "bucket-dev"
#     staging = "bucket-for-staging"
#     qa      = "bucket-name-for-preprod"
#     prod    = "bucket-for-production"
#   }

# }
