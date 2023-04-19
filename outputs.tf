output "task_definition_arn" {
  description = "ARN of the created ECS task definition"
  value       = aws_ecs_task_definition.this.arn
}

output "iam_role_arn" {
  description = "ARN of the created ECS IAM role used to execute the task"
  value       = aws_iam_role.this.arn
}

output "iam_role_name" {
  description = "Name of the created ECS IAM role used to execute the task"
  value       = aws_iam_role.this.name
}
