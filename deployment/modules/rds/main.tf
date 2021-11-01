data "aws_availability_zones" "available" {}

data "aws_secretsmanager_secret" "by-arn" {
  arn = var.aws_secret_manager_secret_arn
}
data "aws_secretsmanager_secret_version" "secret" {
  secret_id = data.aws_secretsmanager_secret.by-arn.id
}
resource "random_string" "finalshot" {
  length  = 5
  special = false
  upper   = false
  number  = false
}
resource "aws_rds_cluster" "postgresql" {
  cluster_identifier        = "cloudvisor-${terraform.workspace}-aurora-cluster-demo"
  engine                    = "aurora-postgresql"
  availability_zones        = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  database_name             = "cloudvisor${terraform.workspace}"
  master_username           = jsondecode(data.aws_secretsmanager_secret_version.secret.secret_string)["db_username"]
  master_password           = jsondecode(data.aws_secretsmanager_secret_version.secret.secret_string)["db_password"]
  backup_retention_period   = 5
  db_subnet_group_name      = aws_db_subnet_group.default.name
  preferred_backup_window   = "07:00-09:00"
  final_snapshot_identifier = random_string.finalshot.result
  vpc_security_group_ids    = [var.rds_cluster_sg.id]
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "cloudvisor-rds-main-${terraform.workspace}"
  subnet_ids = [var.rds_subnet_a.id, var.rds_subnet_b.id, var.rds_subnet_c.id]

  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                = 2
  db_subnet_group_name = aws_db_subnet_group.default.name
  identifier           = "aurora-cluster-demo-${terraform.workspace}-${count.index}"
  cluster_identifier   = aws_rds_cluster.postgresql.id
  instance_class       = terraform.workspace == "dev" ? "db.t3.medium" : "db.r4.large"
  engine               = aws_rds_cluster.postgresql.engine
  engine_version       = aws_rds_cluster.postgresql.engine_version
  publicly_accessible  = terraform.workspace == "dev" ? true : false
}
