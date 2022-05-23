# Create resource group
# with name and region.

resource "azurerm_resource_group" "rg-school" {
  name      = var.resource_group_name
  location  = var.resource_group_location
}
