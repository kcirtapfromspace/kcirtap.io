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
  # Add your access_key and secret_key, or configure your AWS CLI to use profiles.
  # access_key = "your_access_key"
  # secret_key = "your_secret_key"
}

resource "aws_kms_key" "terraform_bucket_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/terraform_bucket_key"
  target_key_id = aws_kms_key.terraform_bucket_key.key_id
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "kcirtapio-tf-state"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_configuration" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_state" {
  name           = "terraform_state"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
