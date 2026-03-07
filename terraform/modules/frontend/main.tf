resource "aws_s3_bucket" "website" {
  bucket = "luan-terraform-website"

  tags = {
    Name = "Website Terraform"
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
  key    = "index.html"
  source = "${path.root}/website/index.html"

  content_type = "text/html"
}

resource "aws_s3_object" "css" {
  bucket = aws_s3_bucket.website.bucket
  key    = "style.css"
  source = "${path.root}/website/style.css"

  content_type = "text/css"
}

resource "aws_cloudfront_distribution" "cdn" {

  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "s3-website"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    target_origin_id = "s3-website"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {

    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "Terraform CDN"
  }
}