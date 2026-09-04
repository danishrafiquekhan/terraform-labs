variable "subscription_id" {
  description = "Azure subscription ID (free-tier lab subscription, never a work/production one). In HCP Terraform this is set as a workspace variable, not from a local terraform.tfvars, see README.md."
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the resource group this exercise creates"
  type        = string
  default     = "rg-terraform-lab-04"
}
