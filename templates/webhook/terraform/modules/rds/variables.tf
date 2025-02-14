variable "identifier" {
  type        = string
  description = "The identifier for the RDS instance"
}

variable "instance_class" {
  type        = string
  description = "The instance class for the RDS instance"
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type        = number
  description = "The allocated storage in GB"
  default     = 20
}

variable "database_name" {
  type        = string
  description = "The name of the database"
}

variable "database_username" {
  type        = string
  description = "The username for the database"
}

variable "database_password" {
  type        = string
  description = "The password for the database"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to the RDS instance"
  default     = {}
}

variable "lambda_security_group_id" {
  description = "Security group ID of the Lambda function"
  type        = string
} 