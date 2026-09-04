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
  default     = "rg-terraform-lab-06"
}

variable "backend_fqdn" {
  description = "FQDN of the web app sitting behind the gateway (placeholder — never a real domain in this repo)"
  type        = string
  default     = "app.example-lab.internal"
}

variable "ssl_cert_key_vault_secret_id" {
  description = "Key Vault secret ID for the gateway's TLS certificate. Placeholder only — a real lab run would point this at a Key Vault secret and give the gateway's managed identity Get access to it."
  type        = string
  default     = "https://kv-example-lab.vault.azure.net/secrets/appgw-cert/<version>"
}

variable "content_security_policy" {
  description = <<-EOT
    The Content-Security-Policy header value. This is deliberately a variable, not a
    hardcoded string, because CSP is application-specific — whatever app sits behind
    this listener has to actually tell me what sources it legitimately needs (scripts,
    styles, fonts, connect-src for its own API, etc). The default below is a
    conservative starting point, not a value I'd ship without the app team confirming
    it doesn't break anything.
  EOT
  type        = string
  default     = "default-src 'self'; object-src 'none'; frame-ancestors 'self'"
}
