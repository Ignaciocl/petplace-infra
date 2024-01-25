resource "aws_s3_bucket" "frontend_app" {
  bucket = "lnt.frontend"
}

resource "aws_s3_bucket" "my_little_bucket" {
  bucket = "my.little.ponny"
}


resource "aws_s3_bucket_public_access_block" "frontend_app" {
  bucket = aws_s3_bucket.frontend_app.id

  block_public_acls   = true
  block_public_policy = true
}
resource "aws_cloudfront_origin_access_identity" "frontend" {
}

resource "aws_s3_bucket_policy" "frontend_app" {
  bucket = aws_s3_bucket.frontend_app.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "frontend_app_cloudfront_policy"
    Statement = [
      {
        "Sid": "1",
        "Effect": "Allow",
        "Principal": {
          "AWS": aws_cloudfront_origin_access_identity.frontend.iam_arn
        },
        "Action": "s3:GetObject",
        "Resource": "${aws_s3_bucket.frontend_app.arn}/*"
      },
    ]
  })
}

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "frontend" {
  origin {
    domain_name = aws_s3_bucket.frontend_app.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  wait_for_deployment = true

  aliases = [var.domain]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]

    compress = true
    cached_methods   = ["GET", "HEAD"]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"

    target_origin_id = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.frontend.certificate_arn
    ssl_support_method  = "sni-only"
  }
}

output "frontend_app_s3_bucket" {
  value = aws_s3_bucket.frontend_app.bucket
}
