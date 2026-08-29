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
  description = "Name of the resource group to create"
  type        = string
  default     = "rg-terraform-lab-05"
}

variable "allowed_ssh_source_cidr" {
  description = "The only CIDR range allowed to reach port 22 — set this to your own IP/32, never 0.0.0.0/0"
  type        = string
}
