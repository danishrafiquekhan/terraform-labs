terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Points at LocalStack (free, local AWS emulation), not real AWS — see
# README.md for why this folder exists and why it uses aws/LocalStack
# instead of azurerm like every other exercise here.
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # LocalStack serves every service off one endpoint, so S3 needs
  # path-style addressing (localhost:4566/bucket-name) instead of the
  # AWS-default virtual-hosted style (bucket-name.s3.amazonaws.com) —
  # without this, the provider's bucket-existence check sends a bare
  # `HEAD /` that LocalStack can't route to any operation, and apply
  # hangs retrying it indefinitely.
  s3_use_path_style = true

  endpoints {
    s3  = "http://localhost:4566"
    iam = "http://localhost:4566"
    sts = "http://localhost:4566"
    ec2 = "http://localhost:4566"
  }
}
