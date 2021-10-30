output "aws_rds_cluster_name" {
  value = aws_rds_cluster.postgresql.database_name
}

output "aws_rds_cluster_host" {
  value = aws_rds_cluster.postgresql.endpoint
}
