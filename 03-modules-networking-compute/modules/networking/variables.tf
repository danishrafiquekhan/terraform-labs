variable "resource_group_name" {
  description = "Resource group the vnet, subnet, and NSG get created in"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to every resource this module creates, so multiple callers don't collide"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the vnet"
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the single subnet this module creates"
  type        = list(string)
  default     = ["10.20.1.0/24"]
}

variable "allowed_ssh_source_cidr" {
  description = "The only CIDR range allowed to reach port 22 on the subnet — your own IP/32, never 0.0.0.0/0 (same lesson as exercise 05)"
  type        = string
}

variable "tags" {
  description = "Tags applied to everything this module creates"
  type        = map(string)
  default     = {}
}
