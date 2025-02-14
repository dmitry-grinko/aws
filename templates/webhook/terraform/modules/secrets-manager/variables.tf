variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod)"
}

variable "database_username" {
  type        = string
  description = "Database username"
}

variable "database_password" {
  type        = string
  description = "Database password"
}

variable "database_name" {
  type        = string
  description = "Database name"
}

variable "database_host" {
  type        = string
  description = "Database host"
}

variable "database_port" {
  type        = number
  description = "Database port"
  default     = 5432
}