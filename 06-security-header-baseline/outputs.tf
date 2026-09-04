output "resource_group_name" {
  description = "Name of the resource group this exercise created"
  value       = azurerm_resource_group.lab.name
}

output "application_gateway_id" {
  description = "Resource ID of the Application Gateway"
  value       = azurerm_application_gateway.lab.id
}

output "public_ip_address" {
  description = "Public IP address assigned to the gateway's frontend"
  value       = azurerm_public_ip.appgw.ip_address
}

output "rewrite_rule_set_name" {
  description = "Name of the rewrite rule set enforcing the header baseline, for reference when wiring up additional listeners"
  value       = "security-header-baseline"
}
