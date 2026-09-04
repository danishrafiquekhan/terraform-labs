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
  description = "Name of the resource group everything in this exercise gets created in"
  type        = string
  default     = "rg-terraform-lab-03"
}

variable "name_prefix" {
  description = "Prefix passed down into both modules so resource names stay unique and identifiable"
  type        = string
  default     = "tflab03"
}

variable "allowed_ssh_source_cidr" {
  description = "The only CIDR range allowed to reach port 22 — your own IP/32, never 0.0.0.0/0"
  type        = string
}

variable "admin_ssh_public_key" {
  description = "Your SSH public key (contents of e.g. ~/.ssh/id_ed25519.pub), never the private key"
  type        = string
}
