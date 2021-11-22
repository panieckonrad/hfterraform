resource "aws_iam_policy" "hf-s3-policy1" {
  name        = "hf-s3-policy1"
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
        "Resource" : "arn:aws:s3:::${var.s3name}"
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

resource "aws_iam_policy" "hf-s3-policy2" {
  name        = "hf-s3-policy2"
  path        = "/"
  description = "allows s3 access for kafka msk connect 2"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "1",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.s3name}",
          "arn:aws:s3:::${var.s3name}/*"
        ]
      },
      {
        "Sid" : "2",
        "Effect" : "Allow",
        "Action" : [
          "kafka:Describe*"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "s3-kafka-connect-role1" {
  name               = "s3-kafka-connect-role1"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "kafkaconnect.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "s3-kafka-connect-role2" {
  name               = "s3-kafka-connect-role2"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "kafkaconnect.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy" "GlueRegistryFullAccess" {
  arn = "arn:aws:iam::aws:policy/AWSGlueSchemaRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "policy_to_role_attachment1" {
  role       = aws_iam_role.s3-kafka-connect-role1.name
  policy_arn = aws_iam_policy.hf-s3-policy1.arn
}

resource "aws_iam_role_policy_attachment" "policy_to_role_attachment1-2" {
  role       = aws_iam_role.s3-kafka-connect-role1.name
  policy_arn = data.aws_iam_policy.GlueRegistryFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "policy_to_role_attachment2" {
  role       = aws_iam_role.s3-kafka-connect-role2.name
  policy_arn = aws_iam_policy.hf-s3-policy2.arn
}

resource "aws_iam_role_policy_attachment" "policy_to_role_attachment2-2" {
  role       = aws_iam_role.s3-kafka-connect-role2.name
  policy_arn = data.aws_iam_policy.GlueRegistryFullAccess.arn
}

resource "aws_iam_instance_profile" "s3-kafka-connect-role1-instance" {
  name = "s3-kafka-connect-role1"
  role = aws_iam_role.s3-kafka-connect-role1.name
}

resource "aws_iam_instance_profile" "s3-kafka-connect-role2-instance" {
  name = "s3-kafka-connect-role2"
  role = aws_iam_role.s3-kafka-connect-role2.name
}



