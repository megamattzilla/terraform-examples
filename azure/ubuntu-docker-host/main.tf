resource "azurerm_resource_group" "main" {
  name     = local.resource_group
  location = local.azure_region
}
