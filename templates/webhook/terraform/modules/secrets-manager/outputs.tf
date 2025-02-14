output "secret_arn" {
  value       = aws_secretsmanager_secret.database_credentials.arn
  description = "ARN of the database credentials secret"
} 