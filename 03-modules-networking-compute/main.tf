resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    purpose = "terraform-learning-lab"
    owner   = "danish-khan-portfolio"
  }
}

module "networking" {
  source = "./modules/networking"

  resource_group_name     = azurerm_resource_group.lab.name
  location                = azurerm_resource_group.lab.location
  name_prefix             = var.name_prefix
  allowed_ssh_source_cidr = var.allowed_ssh_source_cidr

  tags = {
    purpose = "terraform-learning-lab"
  }
}

module "compute" {
  source = "./modules/compute"

  resource_group_name  = azurerm_resource_group.lab.name
  location             = azurerm_resource_group.lab.location
  name_prefix          = var.name_prefix
  subnet_id            = module.networking.subnet_id
  admin_ssh_public_key = var.admin_ssh_public_key

  tags = {
    purpose = "terraform-learning-lab"
  }
}
