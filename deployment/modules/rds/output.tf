output "aws_rds_cluster_name" {
  value = aws_rds_cluster.postgresql.database_name
}

output "aws_rds_cluster_host" {
  value = aws_rds_cluster.postgresql.endpoint
}

output "aws_rds_cluster_ro_host" {
  value = aws_rds_cluster.postgresql.reader_endpoint
}

output "aws_rds_cluster_id"{
  value = aws_rds_cluster.postgresql.id
}