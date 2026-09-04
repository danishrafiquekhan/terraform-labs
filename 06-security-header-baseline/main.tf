resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    purpose = "terraform-learning-lab"
    owner   = "danish-khan-portfolio"
  }
}

resource "azurerm_virtual_network" "lab" {
  name                = "vnet-appgw-lab-06"
  address_space       = ["10.60.0.0/16"]
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
  address_prefixes     = ["10.60.0.0/24"]
}

resource "azurerm_public_ip" "appgw" {
  name                = "pip-appgw-lab-06"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    purpose = "terraform-learning-lab"
  }
}

# --- THE FIX (see BEFORE.md for the gap this closes) ---
# A rewrite rule set applied to every request routed through this gateway, so the
# header baseline holds regardless of what any individual backend app does or forgets
# to do on its own.
resource "azurerm_application_gateway" "lab" {
  name                = "appgw-header-baseline-lab-06"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
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

  ssl_certificate {
    name                = "backend-app-cert"
    key_vault_secret_id = var.ssl_cert_key_vault_secret_id
  }

  backend_address_pool {
    name  = "backend-pool-app"
    fqdns = [var.backend_fqdn]
  }

  backend_http_settings {
    name                  = "backend-http-settings-app"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 30
  }

  http_listener {
    name                           = "listener-app-https"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "port-443"
    protocol                       = "Https"
    ssl_certificate_name           = "backend-app-cert"
  }

  request_routing_rule {
    name                       = "routing-rule-app"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = "listener-app-https"
    backend_address_pool_name  = "backend-pool-app"
    backend_http_settings_name = "backend-http-settings-app"
    rewrite_rule_set_name      = "security-header-baseline"
  }

  rewrite_rule_set {
    name = "security-header-baseline"

    # Add the headers the pen test / scan findings kept flagging as missing or
    # inconsistent across apps. These apply on the response path, after the backend
    # has already answered, so they hold even if the app itself sends nothing at all.
    rewrite_rule {
      name          = "add-security-headers"
      rule_sequence = 100

      response_header_configuration {
        header_name  = "Content-Security-Policy"
        header_value = var.content_security_policy
      }

      response_header_configuration {
        header_name  = "Content-Type"
        header_value = "text/html; charset=UTF-8"
      }

      response_header_configuration {
        header_name  = "Referrer-Policy"
        header_value = "strict-origin-when-cross-origin"
      }

      response_header_configuration {
        header_name  = "Strict-Transport-Security"
        header_value = "max-age=31536000; includeSubDomains"
      }

      response_header_configuration {
        header_name  = "X-Content-Type-Options"
        header_value = "nosniff"
      }

      response_header_configuration {
        header_name  = "X-Frame-Options"
        header_value = "SAMEORIGIN"
      }
    }

    # Blank out the headers that leak framework/server version info — exactly the
    # kind of thing a scanner uses for fingerprinting an easy target.
    rewrite_rule {
      name          = "strip-version-disclosure-headers"
      rule_sequence = 200

      response_header_configuration {
        header_name  = "Server"
        header_value = ""
      }

      response_header_configuration {
        header_name  = "X-AspNet-Version"
        header_value = ""
      }

      response_header_configuration {
        header_name  = "X-AspNetMvc-Version"
        header_value = ""
      }

      response_header_configuration {
        header_name  = "X-Powered-By"
        header_value = ""
      }

      response_header_configuration {
        header_name  = "X-XSS-Protection"
        header_value = ""
      }

      response_header_configuration {
        header_name  = "Expect-CT"
        header_value = ""
      }
    }
  }

  tags = {
    purpose = "terraform-learning-lab"
  }
}
