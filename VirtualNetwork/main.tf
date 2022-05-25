data "azurerm_resource_group" "rg-school" {
  name = "School2022"
}

resource "azurerm_network_security_group" "nsg-school" {
  name                = "school-security-group"
  location            = data.azurerm_resource_group.rg-school.location
  resource_group_name = data.azurerm_resource_group.rg-school.name

  security_rule {
    name                       = "SSH"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "API"
    priority                   = 1200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
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
  
  tags = {
    environment = "Development"
  }
}

# Create subnet
resource "azurerm_subnet" "subnet_1" {
    name = "Subnet1"
    resource_group_name = data.azurerm_resource_group.rg-school.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.1.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "publicIP"
  location            = data.azurerm_resource_group.rg-school.location
  resource_group_name = data.azurerm_resource_group.rg-school.name
  allocation_method   = "Dynamic"
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "networkInterface"
  location            = data.azurerm_resource_group.rg-school.location
  resource_group_name = data.azurerm_resource_group.rg-school.name

  ip_configuration {
    name                          = "NICconf"
    subnet_id                     = azurerm_subnet.subnet_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "assoc_nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg-school.id
}
