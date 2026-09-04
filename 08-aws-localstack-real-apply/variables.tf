variable "bucket_name" {
  description = "S3 bucket name. Must be globally unique even against LocalStack's simulated namespace."
  type        = string
  default     = "soc-lab-log-bucket-localstack"
}
