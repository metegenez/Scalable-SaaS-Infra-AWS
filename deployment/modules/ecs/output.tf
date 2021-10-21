output "ecs_cluster" {
  value = aws_ecs_cluster.node1
}

output "ecs_backend_service" {
  value = aws_ecs_service.node1
}

output "ecs_backend_taskdefinition" {
  value = aws_ecs_task_definition.node1
}

