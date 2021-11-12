resource "aws_s3_bucket" "s3hf" {
  bucket        = "hfs3testing"
  acl           = "private"
  tags          = {
    Name    = "hfs3testing"
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
  key    = "confluentinc-kafka-connect-s3-10.0.3.zip"
  source = "~/Downloads/confluentinc-kafka-connect-s3-10.0.3.zip"
}
resource "aws_s3_bucket_object" "object2" {
  bucket = aws_s3_bucket.s3hf.bucket
  key    = "lenses-connector.jar"
  source = "~/Downloads/kafka-connect-aws-s3-3.0.0-2.5.0-all.jar"
}
