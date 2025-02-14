output "endpoint" {
  value       = aws_db_instance.postgresql.endpoint
  description = "The connection endpoint for the RDS instance"
}

output "database_name" {
  value       = aws_db_instance.postgresql.db_name
  description = "The name of the database"
}

output "port" {
  value       = 5432
  description = "The port the database is listening on"
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.postgresql.arn
} 