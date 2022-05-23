data "azurerm_resource_group" "rg-school" {
  name = "School2022"
}

resource "azurerm_network_security_group" "nsg-school" {
  name                = "school-security-group"
  location            = data.azurerm_resource_group.rg-school.location
  resource_group_name = data.azurerm_resource_group.rg-school.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "school-network"
  location            = data.azurerm_resource_group.rg-school.location
  resource_group_name = data.azurerm_resource_group.rg-school.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = []

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
    security_group = azurerm_network_security_group.nsg-school.id
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
    security_group = azurerm_network_security_group.nsg-school.id
  }

  tags = {
    environment = "Development"
  }
}
