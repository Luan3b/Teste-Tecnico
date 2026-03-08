locals {
  lambda_name = "${var.project_name}-${var.environment}-lambda-daily"
  bucket_name = "${var.project_name}-${var.environment}-daily-files"
}

# Bucket S3
resource "aws_s3_bucket" "daily_bucket" {
  bucket = local.bucket_name
}

# Controle de ownership do bucket
resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.daily_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Role da Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${local.lambda_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Policy da Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${local.lambda_name}-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.daily_bucket.arn}/*"
      },

      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.daily_bucket.arn
      },

      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }

    ]
  })
}

# Compactar código da Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

# Função Lambda
resource "aws_lambda_function" "daily_lambda" {

  depends_on = [
    aws_iam_role_policy.lambda_policy,
    aws_s3_bucket.daily_bucket
  ]

  function_name = local.lambda_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.10"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.daily_bucket.bucket
    }
  }
}

# Regra de agendamento
resource "aws_cloudwatch_event_rule" "daily_rule" {
  name                = "${local.lambda_name}-rule"
  schedule_expression = "cron(0 10 * * ? *)"
}

# Target da regra
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_rule.name
  target_id = "lambda"
  arn       = aws_lambda_function.daily_lambda.arn
}

# Permissão para EventBridge chamar Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.daily_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_rule.arn
}
