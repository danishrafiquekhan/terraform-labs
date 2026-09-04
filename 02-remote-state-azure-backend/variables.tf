variable "subscription_id" {
  description = "Azure subscription ID (free-tier lab subscription, never a work/production one)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the resource group this exercise's own resources live in (not the backend storage account, that gets bootstrapped separately, see README)"
  type        = string
  default     = "rg-terraform-lab-02"
}

variable "storage_account_name" {
  description = "Name of the storage account created in this exercise, just to have something with actual state worth locking. Must be globally unique, lowercase, no dashes."
  type        = string
  default     = "sttflab02demo"
}
