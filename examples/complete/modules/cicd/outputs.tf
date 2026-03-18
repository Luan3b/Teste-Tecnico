output "pipeline_name" {
  value = aws_codepipeline.pipeline.name
}

output "codebuild_project_name" {
  value = aws_codebuild_project.build.name
}

output "artifacts_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}

output "pipeline_arn" {
  value = aws_codepipeline.pipeline.arn
}