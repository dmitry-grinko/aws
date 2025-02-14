resource "aws_db_instance" "postgresql" {
  identifier        = var.identifier
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  db_name  = var.database_name
  username = var.database_username
  password = var.database_password

  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds.id]

  tags = var.tags
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.identifier}-rds-sg"
  description = "Security group for RDS PostgreSQL instance"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.lambda_security_group_id]  # Allow access from Lambda
  }

  tags = var.tags
}