output "resource_group_name" {
  description = "Name of the resource group this exercise created"
  value       = azurerm_resource_group.lab.name
}

output "waf_policy_id" {
  description = "Resource ID of the WAF policy backing this gateway"
  value       = azurerm_web_application_firewall_policy.pilot.id
}

output "waf_policy_mode" {
  description = "Current WAF mode — should read Detection until the false-positive review is done, see README"
  value       = azurerm_web_application_firewall_policy.pilot.policy_settings[0].mode
}

output "application_gateway_id" {
  description = "Resource ID of the Application Gateway"
  value       = azurerm_application_gateway.lab.id
}

output "apim_dev_listener_hostname" {
  description = "Custom hostname bound to the new APIM dev pilot listener"
  value       = var.apim_dev_hostname
}
