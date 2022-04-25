# Creating a Ubuntu VM using Terraform on Azure.


### 1- Define Provider
Check the full file [here](../terraform-vm-code/vm-code/main.tf)

First of all, lets define the provide. 

```
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

### 2- Define Resources

Check the full file [here](../terraform-vm-code/vm-code/resources.tf)

```
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
```


### 3- Plan


```
terraform init
```

Execute the command below and check the result 

```
terraform plan
```

Result:
```
Terraform will perform the following actions:

  # azurerm_linux_virtual_machine.vm01 will be created
  + resource "azurerm_linux_virtual_machine" "vm01" {
      + admin_username                  = "adminuser"
      + allow_extension_operations      = true
      + computer_name                   = (known after apply)
      + disable_password_authentication = true
      + extensions_time_budget          = "PT1H30M"
      + id                              = (known after apply)
      + location                        = "eastus2"
      + max_bid_price                   = -1
      + name                            = "virtual-machine-linux01"
      + network_interface_ids           = (known after apply)
      + patch_mode                      = "ImageDefault"
      + platform_fault_domain           = -1
      + priority                        = "Regular"
      + private_ip_address              = (known after apply)
      + private_ip_addresses            = (known after apply)
      + provision_vm_agent              = true
      + public_ip_address               = (known after apply)
      + public_ip_addresses             = (known after apply)
      + resource_group_name             = "rg_vm"
      + size                            = "Standard_B1"
      + virtual_machine_id              = (known after apply)

      + admin_ssh_key {
          + public_key = <<-EOT
                ssh-rsa AAAAB3N
            EOT
          + username   = "adminuser"
        }

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + name                      = (known after apply)
          + storage_account_type      = "Standard_LRS"
          + write_accelerator_enabled = false
        }

      + source_image_reference {
          + offer     = "UbuntuServer"
          + publisher = "Canonical"
          + sku       = "16.04-LTS"
          + version   = "latest"
        }

      + termination_notification {
          + enabled = (known after apply)
          + timeout = (known after apply)
        }
    }

  # azurerm_network_interface.ninter will be created
  + resource "azurerm_network_interface" "ninter" {
      + applied_dns_servers           = (known after apply)
      + dns_servers                   = (known after apply)
      + enable_accelerated_networking = false
      + enable_ip_forwarding          = false
      + id                            = (known after apply)
      + internal_dns_name_label       = (known after apply)
      + internal_domain_name_suffix   = (known after apply)
      + location                      = "eastus2"
      + mac_address                   = (known after apply)
      + name                          = "network_interface"
      + private_ip_address            = (known after apply)
      + private_ip_addresses          = (known after apply)
      + resource_group_name           = "rg_vm"
      + virtual_machine_id            = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "internal"
          + primary                                            = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = "Dynamic"
          + private_ip_address_version                         = "IPv4"
          + subnet_id                                          = (known after apply)
        }
    }

  # azurerm_resource_group.rg will be created
  + resource "azurerm_resource_group" "rg" {
      + id       = (known after apply)
      + location = "eastus2"
      + name     = "rg_vm"
    }

  # azurerm_subnet.snet will be created
  + resource "azurerm_subnet" "snet" {
      + address_prefixes                               = [
          + "10.0.2.0/24",
        ]
      + enforce_private_link_endpoint_network_policies = false
      + enforce_private_link_service_network_policies  = false
      + id                                             = (known after apply)
      + name                                           = "internal"
      + resource_group_name                            = "rg_vm"
      + location            = "eastus2"
      + name                = "network"
      + resource_group_name = "rg_vm"
      + subnet              = (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.
```

### 4- Apply and/ or destroy

After to check the plan, now we will apply the infra changes

```
terraform apply
```

If you want to destroy the infraestructure, it is simple. Execute the command below.

```
terraform destroy
```

