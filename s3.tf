resource "aws_s3_bucket" "s3hf" {
  bucket        = "s3hftest"
  acl           = "private"
  force_destroy = true
  tags          = {
    Name    = "s3hftest"
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

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.s3hf.bucket
  key    = "kafka-connect-aws-s3"
  source = "~/Downloads/kafka-connect-aws-s3-2.1.3.1-2.5.0-all.jar"
}
