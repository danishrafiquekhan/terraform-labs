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
  default     = "rg-terraform-lab-07"
}

variable "website_hostname" {
  description = "Hostname for the existing website listener already served through this gateway (placeholder, never a real domain in this repo)"
  type        = string
  default     = "www.example-lab.internal"
}

variable "website_backend_fqdn" {
  description = "FQDN of the existing website backend"
  type        = string
  default     = "app.example-lab.internal"
}

variable "website_ssl_cert_key_vault_secret_id" {
  description = "Key Vault secret ID for the existing website listener's TLS certificate. Placeholder only."
  type        = string
  default     = "https://kv-example-lab.vault.azure.net/secrets/website-cert/<version>"
}

variable "apim_dev_hostname" {
  description = "New custom hostname being piloted for the APIM dev listener (placeholder, never a real domain in this repo)"
  type        = string
  default     = "api-dev.example-lab.internal"
}

variable "apim_dev_backend_fqdn" {
  description = "FQDN of the APIM dev instance's gateway endpoint (placeholder — fictional, this is a dev/non-prod instance being used for the WAF detection-mode pilot only)"
  type        = string
  default     = "apim-dev-example.azure-api.net"
}

variable "apim_dev_ssl_cert_key_vault_secret_id" {
  description = "Key Vault secret ID for the APIM dev listener's TLS certificate. Placeholder only."
  type        = string
  default     = "https://kv-example-lab.vault.azure.net/secrets/apim-dev-cert/<version>"
}
