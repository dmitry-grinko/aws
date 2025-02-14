# Create the Secrets Manager secret for database credentials
resource "aws_secretsmanager_secret" "database_credentials" {
  name        = "${var.environment}-database-credentials"
  description = "Database credentials for ${var.environment} environment"

  tags = {
    Environment = var.environment
  }
}

# Store the database credentials in the secret
resource "aws_secretsmanager_secret_version" "database_credentials" {
  secret_id = aws_secretsmanager_secret.database_credentials.id
  secret_string = jsonencode({
    username = var.database_username
    password = var.database_password
    name     = var.database_name
    host     = var.database_host
    port     = var.database_port
  })
}
