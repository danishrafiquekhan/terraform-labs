output "resource_group_name" {
  description = "Name of the resource group this exercise created"
  value       = azurerm_resource_group.lab.name
}
