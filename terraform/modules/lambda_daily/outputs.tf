output "scheduler_bucket_name" {
  value = aws_s3_bucket.daily_bucket.bucket
}

output "lambda_name" {
  value = aws_lambda_function.daily_lambda.function_name
}