terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # HCP Terraform (the product formerly called Terraform Cloud) as the
  # backend and execution environment. Organization and workspace are
  # placeholders, see README.md for how the real ones get set without
  # committing them here.
  cloud {
    organization = "<your-hcp-terraform-org>"

    workspaces {
      name = "terraform-labs-04"
    }
  }
}

provider "azurerm" {
  features {}
  # Auth here does NOT come from `az login` like the other exercises.
  # HCP Terraform runs applies on its own remote workers, which have no
  # access to my local az CLI session. Instead auth comes from an
  # ARM_CLIENT_ID / ARM_CLIENT_SECRET / ARM_TENANT_ID service principal set
  # as workspace environment variables (marked sensitive), never from
  # anything in this repo. See README.md.
  subscription_id = var.subscription_id
}
