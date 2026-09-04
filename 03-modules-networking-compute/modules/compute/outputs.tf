output "vm_id" {
  description = "ID of the VM this module created"
  value       = azurerm_linux_virtual_machine.this.id
}

output "private_ip_address" {
  description = "Private IP of the VM's network interface"
  value       = azurerm_network_interface.this.private_ip_address
}
