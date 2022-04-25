
# 1- Create resource group 

resource "azurerm_resource_group" "rg" {
  name = "rg_vm"
  location = "eastus2"
}

# 2- Create virtual network

resource "azurerm_virtual_network" "vnet" {
  name                = "network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 3- create subnet

resource "azurerm_subnet" "snet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
# 4- create network interface

resource "azurerm_network_interface" "ninter" {
  name                = "network_interface"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 5- Create linux VM

resource "azurerm_linux_virtual_machine" "vm01" {
  name                = "virtual-machine-linux01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.ninter.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    # generate .pub use the command "ssh-keygen -o"
    public_key = file("~/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}