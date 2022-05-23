data "azurerm_resource_group" "rg-school" {
  name = "School2022"
}

resource "azurerm_storage_account" "school2022endava" {
  name                     = "school2022endava"
  resource_group_name      = data.azurerm_resource_group.rg-school.name
  location                 = "eastus"
  account_kind		   = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "sc-school" {
  name                  = "schoolvhds"
  storage_account_name  = azurerm_storage_account.school2022endava.name
  container_access_type = "blob"
}
