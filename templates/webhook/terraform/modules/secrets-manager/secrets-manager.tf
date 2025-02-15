# Add random suffix to avoid name conflicts
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create the Secrets Manager secret for database credentials
resource "aws_secretsmanager_secret" "database_credentials" {
  name = "${var.environment}-db-creds-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
  
  # Optionally, you can set force_delete to true to avoid the recovery window
  force_overwrite_replica_secret = true
  recovery_window_in_days       = 0  # Set to 0 to force immediate deletion

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
