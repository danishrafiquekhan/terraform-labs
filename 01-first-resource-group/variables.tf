variable "subscription_id" {
  description = "Azure subscription ID (free-tier lab subscription, never a work/production one)"
  type        = string
}

variable "location" {
  description = "Azure region for the resource group"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
  default     = "rg-terraform-lab-01"
}
