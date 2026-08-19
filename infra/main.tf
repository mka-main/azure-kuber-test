resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

module "storage" {
  source = "./modules/storage"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  unique_suffix       = var.unique_suffix
  tags                = var.tags
}

resource "azurerm_container_registry" "this" {
  name                = "acrmkatf${var.unique_suffix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}

module "aks" {
  source = "./modules/aks"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  aks_name            = var.aks_name
  dns_prefix          = "${var.aks_name}${var.unique_suffix}"
  node_vm_size        = var.node_vm_size
  node_count          = var.node_count
  acr_id              = azurerm_container_registry.this.id
  tags                = var.tags
}
