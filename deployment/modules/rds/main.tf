data "aws_availability_zones" "available" {}

resource "aws_rds_cluster" "postgresql" {
  cluster_identifier      = "cloudvisor-${terraform.workspace}-aurora-cluster-demo"
  engine                  = "aurora-postgresql"
  availability_zones      = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  database_name           = "cloudvisor${terraform.workspace}"
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"

  engine_mode = "serverless"

  scaling_configuration {
    auto_pause               = true
    max_capacity             = 4
    min_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}
