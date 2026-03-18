resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-${var.environment}-website"

  tags = {
    Name = "Website ${var.project_name} ${var.environment}"
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website.id

  depends_on = [
    aws_s3_bucket_public_access_block.website
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index" {

  bucket = aws_s3_bucket.website.bucket

  key = "index.html"

  content = data.template_file.index.rendered

  content_type = "text/html"
}

resource "aws_s3_object" "css" {
  bucket = aws_s3_bucket.website.bucket
  key    = "style.css"
  source = "${path.module}/../../../app/frontend/style.css"

  content_type = "text/css"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  # ORIGEM 1: Seu S3 (Site)
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "s3-website"
  }

  # ORIGEM 2: Seu Backend (ALB)
  origin {
    domain_name = var.backend_url # O DNS do seu Load Balancer
    origin_id   = "backend-alb"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # O CloudFront fala HTTP com o ALB
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # COMPORTAMENTO PADRÃO: S3 (Site)
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-website"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  # COMPORTAMENTO PARA A API: Redireciona /files para o ALB
  ordered_cache_behavior {
    path_pattern     = "/files*"
    target_origin_id = "backend-alb"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies { forward = "all" }
    }

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "template_file" "index" {
  template = file("${path.module}/../../../app/frontend/index.html.tpl")

  vars = {
    backend_url = var.backend_url
  }
}