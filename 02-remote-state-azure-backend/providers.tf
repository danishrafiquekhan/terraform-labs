terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Backend block is deliberately left empty. Real values (resource group,
  # storage account, container, key) come from backend.hcl at `terraform init`
  # time via -backend-config, not from anything committed here.
  # See README.md for why and backend.hcl.example for the shape of that file.
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  # Auth comes from `az login` (Azure CLI) — no credentials are stored here.
  subscription_id = var.subscription_id
}
