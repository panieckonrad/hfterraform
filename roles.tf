resource "aws_iam_policy" "hf-s3-policy" {
  name        = "hf-s3-policy"
  path        = "/"
  description = "allows s3 access for kafka msk connect"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListAllMyBuckets"
        ],
        "Resource" : "arn:aws:s3:::*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : "arn:aws:s3:::s3hftest"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucketMultipartUploads"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "s3-kafka-connect-role" {
  name               = "s3-kafka-connect-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "kafkaconnect.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_to_role_attachment" {
  role       = aws_iam_role.s3-kafka-connect-role.name
  policy_arn = aws_iam_policy.hf-s3-policy.arn
}