output "resource_group_name" {
  description = "Name of the resource group this exercise created"
  value       = azurerm_resource_group.lab.name
}

output "storage_account_name" {
  description = "Name of the demo storage account (not the backend one, this is just a resource to prove remote state works)"
  value       = azurerm_storage_account.demo.name
}
