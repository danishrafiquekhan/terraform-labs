output "vnet_id" {
  description = "ID of the vnet this module created"
  value       = azurerm_virtual_network.this.id
}

output "subnet_id" {
  description = "ID of the subnet, consumed by the compute module's network interface"
  value       = azurerm_subnet.this.id
}

output "nsg_id" {
  description = "ID of the network security group associated with the subnet"
  value       = azurerm_network_security_group.this.id
}
