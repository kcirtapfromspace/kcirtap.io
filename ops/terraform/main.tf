terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         =  "kcirtapio-tf-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform_state"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  domain_name = "kcirtap.io"
}

# S3 bucket to host the static site
resource "aws_s3_bucket_website_configuration" "site" {
  bucket = local.domain_name
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

# ACM SSL certificate
resource "aws_acm_certificate" "site_cert" {
  domain_name       = local.domain_name
  validation_method = "DNS"

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
    for dvo in aws_acm_certificate.site_cert_validation.domain_validation_options : dvo.domain_name => {
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

# CloudFront distribution
resource "aws_cloudfront_distribution" "site_distribution" {
  origin {
    domain_name = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id   = local.domain_name

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.domain_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site_cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
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
resource "aws_route53_record" "site" {
  name    = local.domain_name
  type    = "A"
  zone_id = "Z0925866K024YRD6EBOT"

  alias {
    name                   = aws_cloudfront_distribution.site_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.site_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
