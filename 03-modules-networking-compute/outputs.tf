output "vnet_id" {
  description = "ID of the vnet created by the networking module"
  value       = module.networking.vnet_id
}

output "subnet_id" {
  description = "ID of the subnet the VM's NIC is attached to"
  value       = module.networking.subnet_id
}

output "vm_private_ip" {
  description = "Private IP address of the VM created by the compute module"
  value       = module.compute.private_ip_address
}
