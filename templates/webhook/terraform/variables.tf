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
