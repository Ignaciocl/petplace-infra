resource "aws_s3_bucket" "envBucket" {
  bucket = "${var.envBucket}terraform"
}

resource "aws_iam_policy" "bucket-read" {
  name        = "${module.vpc.name}-${var.region}-task-policy-bucket-read"
  description = "Policy that allows access to read from the bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.envBucket.bucket}/drugsEnvFile.env"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.envBucket.bucket}"
      ]
    }
  ]
}
EOF
}
