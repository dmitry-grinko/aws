variable "aws-region" {
  description = "AWS region"
  type        = string
}

variable "aws-access-key-id" {
  description = "AWS access key"
  type        = string
}

variable "aws-secret-access-key" {
  description = "AWS secret key"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "database_password" {
  type        = string
  description = "The password for the RDS database"
  sensitive   = true
}

variable "database_name" {
  type        = string
  description = "The name of the RDS database"
}

variable "database_username" {
  type        = string
  description = "The username for the RDS database"
}


