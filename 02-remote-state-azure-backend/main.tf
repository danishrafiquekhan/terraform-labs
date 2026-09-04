resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    purpose = "terraform-learning-lab"
    owner   = "danish-khan-portfolio"
  }
}

# Not a critical resource, just something with real state worth demonstrating
# remote state and locking against. A storage account is also thematically
# convenient here since the backend itself is one.
resource "azurerm_storage_account" "demo" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = {
    purpose = "terraform-learning-lab"
  }
}
