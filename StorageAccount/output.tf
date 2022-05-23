output "resource_group_name" {
    value = data.azurerm_resource_group.rg-school.name
}

output "storage_account_name" {
    value = azurerm_storage_account.school2022endava.name
}

output "storage_container_name" {
    value = azurerm_storage_container.sc-school.name
}

output "storage_container_access_type" {
    value = azurerm_storage_container.sc-school.container_access_type
}
