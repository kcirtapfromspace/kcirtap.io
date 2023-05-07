terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         =  "kcirtapio-tf-state"
    key            = "kcirtap-io/ops/terraform/terraform.tfstate"
    region         = "us-east-1"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "kcirtapio_terraform_state_ops"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  domain_name = "kcirtap.io"
  tags = {
    Terraform = "true"
  }
}


resource "aws_s3_bucket" "site" {
  bucket = local.domain_name
  tags = {
    Terraform = "true"
  }
}


resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "site" {
  depends_on = [aws_s3_bucket_ownership_controls.site]

  bucket = aws_s3_bucket.site.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "site_public_read" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2008-10-17"
    Id      = "PolicyForCloudFrontPrivateContent"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.site.bucket}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.site_distribution.arn
          }
        }
      }
    ]
  })
}


# S3 bucket to host the static site
resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
}

# ACM SSL certificate
resource "aws_acm_certificate" "site_cert" {
  domain_name       = data.aws_route53_zone.site.name
  subject_alternative_names        = [data.aws_route53_zone.site.name]
  validation_method = "DNS"
  # key_algorithm ="EC_secp384r1" # Does not work with CloudFront

  tags = {
    Terraform = "true",
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone"  "site" {
  name         = local.domain_name
  private_zone = false
}

# ACM SSL certificate validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.site_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.site.zone_id
}

resource "aws_acm_certificate_validation" "site_cert_validation" {
  certificate_arn         = aws_acm_certificate.site_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = aws_s3_bucket.site.bucket_regional_domain_name
  description                       = "Allow CloudFront to reach the S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource aws_cloudfront_origin_access_identity "site" {
  comment = "Allow CloudFront to reach the S3 bucket"
}

data "aws_cloudfront_cache_policy" "site" {
  name = "Managed-CachingOptimized"
}
data "aws_cloudfront_origin_request_policy" "site" {
  name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
}
data "aws_cloudfront_response_headers_policy" "site" {
  name = "Managed-CORS-with-preflight-and-SecurityHeadersPolicy"
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "site_distribution" {
  origin {
    domain_name = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id   = data.aws_route53_zone.site.name
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id

  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  http_version = "http2and3"
  aliases = [local.domain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = data.aws_route53_zone.site.name
    cache_policy_id = data.aws_cloudfront_cache_policy.site.id
    # origin_request_policy_id = data.aws_cloudfront_origin_request_policy.site.id # Does not work with CloudFront & S3


    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  
  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site_cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Terraform = "true"
  }
}

# Route 53 record for the domain
resource "aws_route53_record" "site_A" {
  name    = data.aws_route53_zone.site.name
  type    = "A"
  zone_id = data.aws_route53_zone.site.zone_id

  alias {
    name                   = aws_cloudfront_distribution.site_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.site_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "site_AAAA" {
  name    = data.aws_route53_zone.site.name
  type    = "AAAA"
  zone_id = data.aws_route53_zone.site.zone_id

  alias {
    name                   = aws_cloudfront_distribution.site_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.site_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
