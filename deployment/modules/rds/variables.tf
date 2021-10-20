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

variable "rds_cluster_sg" {
  description = "DB security group"
}

variable "rds_subnet_a" {
}

variable "rds_subnet_b" {
}

variable "rds_subnet_c" {
}
