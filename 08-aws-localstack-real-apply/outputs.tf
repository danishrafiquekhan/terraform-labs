output "bucket_arn" {
  value = aws_s3_bucket.logs.arn
}

output "log_writer_role_arn" {
  value = aws_iam_role.log_writer.arn
}
