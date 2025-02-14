# IAM role for Lambda execution
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.function_name}-role-${random_string.suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.tags
}

# Basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy for RDS access
data "aws_iam_policy_document" "lambda_rds_access" {
  statement {
    actions = [
      "rds-db:connect",
      "rds:*"
    ]
    resources = [
      "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:db:${var.function_name}-db",
      "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:*/${var.function_name}"
    ]
  }

  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses"
    ]
    resources = ["*"]
  }
}

# Get current AWS region and account ID
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Create the RDS access policy
resource "aws_iam_policy" "lambda_rds_access" {
  name        = "${var.function_name}-rds-access-${random_string.suffix.result}"
  description = "IAM policy for Lambda to access RDS"
  policy      = data.aws_iam_policy_document.lambda_rds_access.json
}

# Attach the RDS access policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_rds_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_rds_access.arn
} 


resource "aws_iam_role_policy" "additional_policies" {
  count = length(var.additional_policies)
  name  = "additional-policy-${count.index}"
  role  = aws_iam_role.lambda_role.id
  policy = var.additional_policies[count.index]
}