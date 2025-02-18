output "rds_endpoint" {
  value       = module.rds.endpoint
  description = "The connection endpoint for the RDS instance"
}

output "rds_database_name" {
  value       = module.rds.database_name
  description = "The name of the database"
}

output "rds_port" {
  value       = module.rds.port
  description = "The port the database is listening on"
}

output "rds_instance_arn" {
  value       = module.rds.db_instance_arn
  description = "The ARN of the RDS instance"
}