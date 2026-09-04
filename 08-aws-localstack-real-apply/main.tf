resource "aws_s3_bucket" "logs" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "log_writer" {
  name = "${var.bucket_name}-log-writer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "log_writer_put_only" {
  name = "put-objects-only"
  role = aws_iam_role.log_writer.id

  # Deliberately narrow: PutObject only, no Get/List/Delete. A role that
  # writes logs doesn't need to read or delete them — this is the same
  # least-privilege principle from the Auth0 lesson in detection-engineering,
  # applied here in Terraform instead of caught after the fact via an API.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject"]
      Resource = "${aws_s3_bucket.logs.arn}/*"
    }]
  })
}
