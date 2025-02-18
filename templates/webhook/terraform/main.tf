locals {
  tags = {
    Environment = var.environment
    Name        = var.project_name
  }
}

module "vpc" {
  source = "./modules/vpc"

  environment = var.environment
  vpc_cidr    = "10.0.0.0/16"
}

module "secrets_manager" {
  source = "./modules/secrets-manager"

  environment       = var.environment
  database_username = var.database_username
  database_password = var.database_password
  database_name     = var.database_name
  database_host     = element(split(":", module.rds.endpoint), 0)
  database_port     = 5432
}

module "rds" {
  source = "./modules/rds"

  identifier               = "${var.project_name}-db"
  database_name            = var.database_name
  database_username        = var.database_username
  database_password        = var.database_password
  instance_class           = "db.t3.micro"
  allocated_storage        = 20
  lambda_security_group_id = module.lambda.security_group_id
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnet_ids
  tags                     = local.tags
  depends_on               = [module.vpc]
}

module "lambda" {
  source = "./modules/lambda"

  function_name      = var.project_name
  environment        = var.environment
  runtime            = "nodejs20.x"
  handler            = "index.handler"
  log_retention_days = 14
  filename           = "../backend/function.zip"
  tags               = local.tags
  vpc_id             = module.vpc.vpc_id
  
  environment_variables = {
    SECRETS_ARN = module.secrets_manager.secret_arn
  }

  # Add permissions to access Secrets Manager
  additional_policies = [
    jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Resource = [module.secrets_manager.secret_arn]
        }
      ]
    })
  ]
}

module "api_gateway" {
  source = "./modules/api-gateway"

  name                 = "${var.project_name}-api"
  environment          = var.environment
  lambda_function_arn  = module.lambda.function_arn
  lambda_function_name = module.lambda.function_name
  tags                 = local.tags
  depends_on           = [module.lambda]
}
