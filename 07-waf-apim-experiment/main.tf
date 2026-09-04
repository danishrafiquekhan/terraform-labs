resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    purpose = "terraform-learning-lab"
    owner   = "danish-khan-portfolio"
  }
}

resource "azurerm_virtual_network" "lab" {
  name                = "vnet-appgw-lab-07"
  address_space       = ["10.70.0.0/16"]
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  tags = {
    purpose = "terraform-learning-lab"
  }
}

resource "azurerm_subnet" "appgw" {
  name                 = "snet-appgw"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.70.0.0/24"]
}

resource "azurerm_public_ip" "appgw" {
  name                = "pip-appgw-lab-07"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    purpose = "terraform-learning-lab"
  }
}

# --- WAF policy for the pilot, Detection mode on purpose (see README) ---
# Same managed ruleset the existing website listener would run under, so this
# experiment is actually measuring "how does this ruleset behave against APIM
# traffic", not a different ruleset than production already trusts.
resource "azurerm_web_application_firewall_policy" "pilot" {
  name                = "waf-apim-dev-pilot-lab-07"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location

  policy_settings {
    enabled                     = true
    mode                        = "Detection" # not Prevention — see README for why
    file_upload_limit_in_mb     = 100
    request_body_check          = true
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  tags = {
    purpose = "terraform-learning-lab"
  }
}

resource "azurerm_application_gateway" "lab" {
  name                = "appgw-waf-apim-pilot-lab-07"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  firewall_policy_id  = azurerm_web_application_firewall_policy.pilot.id

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = "port-443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  # --- Existing website listener ---
  # Standing in for what's already live on this gateway today. Included here so the
  # new APIM listener below reads as an addition to something real, not a gateway
  # built from scratch just for this experiment.
  ssl_certificate {
    name                = "website-cert"
    key_vault_secret_id = var.website_ssl_cert_key_vault_secret_id
  }

  backend_address_pool {
    name  = "backend-pool-website"
    fqdns = [var.website_backend_fqdn]
  }

  backend_http_settings {
    name                  = "backend-http-settings-website"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 30
  }

  http_listener {
    name                           = "listener-website-https"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "port-443"
    protocol                       = "Https"
    host_name                      = var.website_hostname
    ssl_certificate_name           = "website-cert"
  }

  request_routing_rule {
    name                       = "routing-rule-website"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = "listener-website-https"
    backend_address_pool_name  = "backend-pool-website"
    backend_http_settings_name = "backend-http-settings-website"
  }

  # --- New: APIM dev pilot listener ---
  # A second host-based (SNI) listener on the same frontend IP/port, routed to the
  # APIM dev instance's gateway endpoint instead of the website backend. Backed by
  # the same WAF policy above, currently in Detection mode.
  ssl_certificate {
    name                = "apim-dev-cert"
    key_vault_secret_id = var.apim_dev_ssl_cert_key_vault_secret_id
  }

  backend_address_pool {
    name  = "backend-pool-apim-dev"
    fqdns = [var.apim_dev_backend_fqdn]
  }

  probe {
    name                                      = "probe-apim-dev"
    protocol                                  = "Https"
    path                                      = "/status-0123456789abcdef" # APIM's built-in health endpoint
    host                                      = var.apim_dev_backend_fqdn
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false
  }

  backend_http_settings {
    name                  = "backend-http-settings-apim-dev"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 30
    probe_name            = "probe-apim-dev"
  }

  http_listener {
    name                           = "listener-apim-dev-https"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "port-443"
    protocol                       = "Https"
    host_name                      = var.apim_dev_hostname
    ssl_certificate_name           = "apim-dev-cert"
  }

  request_routing_rule {
    name                       = "routing-rule-apim-dev"
    rule_type                  = "Basic"
    priority                   = 200
    http_listener_name         = "listener-apim-dev-https"
    backend_address_pool_name  = "backend-pool-apim-dev"
    backend_http_settings_name = "backend-http-settings-apim-dev"
  }

  tags = {
    purpose = "terraform-learning-lab"
  }
}
