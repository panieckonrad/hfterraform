resource "aws_s3_bucket" "s3hf" {
  bucket = var.s3name
  acl    = "private"
  tags   = {
    Name    = var.s3name
    Pricing = "hf"
  }
}

resource "aws_s3_bucket_public_access_block" "s3hf" {
  bucket                  = aws_s3_bucket.s3hf.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
