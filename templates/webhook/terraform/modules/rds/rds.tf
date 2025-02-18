resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = var.tags
}

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
  publicly_accessible    = true  # Changed to true for public access
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  # Enable SSL/TLS encryption
  storage_encrypted = true
  
  # Force SSL connections
  parameter_group_name = aws_db_parameter_group.postgresql.name

  tags = var.tags
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.identifier}-rds-sg"
  description = "Security group for RDS PostgreSQL instance"
  vpc_id      = var.vpc_id

  # Allow access from Lambda
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.lambda_security_group_id]
  }

  # Allow public access for testing
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Add a parameter group to enforce SSL
resource "aws_db_parameter_group" "postgresql" {
  family = "postgres16"
  name   = "${var.identifier}-pg"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  tags = var.tags
}