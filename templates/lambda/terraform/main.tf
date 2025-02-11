locals {
  tags = {
    Environment = var.environment
    Name        = var.project_name
  }
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
}

module "api_gateway" {
  source = "./modules/api-gateway"
  
  name                 = "${var.project_name}-api"
  environment          = var.environment
  lambda_function_arn  = module.lambda.function_arn
  lambda_function_name = module.lambda.function_name
  tags                 = local.tags
}
