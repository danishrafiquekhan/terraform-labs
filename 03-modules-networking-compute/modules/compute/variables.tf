variable "resource_group_name" {
  description = "Resource group the VM and its NIC get created in"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to every resource this module creates"
  type        = string
}

variable "subnet_id" {
  description = "Subnet the VM's network interface attaches to (comes from the networking module's output, not hardcoded)"
  type        = string
}

variable "vm_size" {
  description = "VM size — kept to a free-tier-eligible B-series size on purpose"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "labadmin"
}

variable "admin_ssh_public_key" {
  description = "Your SSH public key (the .pub file contents, never the private key). Password auth is disabled entirely, see main.tf."
  type        = string
}

variable "tags" {
  description = "Tags applied to everything this module creates"
  type        = map(string)
  default     = {}
}
