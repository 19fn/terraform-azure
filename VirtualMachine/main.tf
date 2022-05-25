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

# Create an SSH key
resource "tls_private_key" "key_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "Ubuntu-Server"
  location              = data.azurerm_resource_group.rg-school.location
  resource_group_name   = data.azurerm_resource_group.rg-school.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "vm_disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = var.computer_name
  admin_username                  = var.admin_user
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_user
    public_key = tls_private_key.key_ssh.public_key_openssh
  }

  # Remote connection
  connection {
    type = "ssh"
    host = self.public_ip_address
    user = var.admin_user
    private_key = tls_private_key.key_ssh.private_key_openssh
    timeout = "5m"
  }

    provisioner "remote-exec" {
       inline = [
                        "sudo apt-get update",
                        "cd /opt && sudo git clone https://github.com/19fn/docker-pack.git",
                        "sudo /bin/bash /opt/docker-pack/install.sh"
                ]
        }
}
