resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    purpose = "terraform-learning-lab"
    owner   = "danish-khan-portfolio"
  }
}

resource "azurerm_network_security_group" "lab" {
  name                = "nsg-terraform-lab-05"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  # --- THE FIX (see BEFORE.md for the deliberate misconfiguration this replaced) ---
  # Only allow SSH from a specific, known IP range, never 0.0.0.0/0.
  security_rule {
    name                       = "AllowSSHFromKnownRange"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_source_cidr
    destination_address_prefix = "*"
  }

  tags = {
    purpose = "terraform-learning-lab"
  }
}
