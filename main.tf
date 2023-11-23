# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.81.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "jenkins-terraform-test" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_virtual_network" "jenkins-terraform-test-network" {
  name                = "jenkins-terraform-test-network"
  address_space       = var.address_space
  location            = azurerm_resource_group.jenkins-terraform-test.location
  resource_group_name = azurerm_resource_group.jenkins-terraform-test.name

}
resource "azurerm_subnet" "jenkins-terraform-test-subnet1" {
  name                 = "jenkins-terraform-subnet1"
  resource_group_name  = azurerm_resource_group.jenkins-terraform-test.name
  virtual_network_name = azurerm_virtual_network.jenkins-terraform-test-network.name
  address_prefixes     = var.address_prefixes
}
resource "azurerm_public_ip" "jenkins-terraform-test-publicip" {
  name                = "mypubliip"
  location            = azurerm_resource_group.jenkins-terraform-test.location
  resource_group_name = azurerm_resource_group.jenkins-terraform-test.name
  allocation_method   = "Dynamic"

}
resource "azurerm_network_interface" "jenkins-terraform-test-nic" {
  name                = "jenkins-terraform-test-nic"
  location            = azurerm_resource_group.jenkins-terraform-test.location
  resource_group_name = azurerm_resource_group.jenkins-terraform-test.name

  ip_configuration {
    name                          = "jenkins-terraform-test-ipconfiguration"
    subnet_id                     = azurerm_subnet.jenkins-terraform-test-subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins-terraform-test-publicip.id
  }
}
resource "azurerm_linux_virtual_machine" "jenkins-terraform-test-vm" {
  name                            = "jenkins-terraform-test-firstvm"
  resource_group_name             = azurerm_resource_group.jenkins-terraform-test.name
  location                        = "eastus"
  network_interface_ids           = [azurerm_network_interface.jenkins-terraform-test-nic.id]
  size                            = "Standard_B1s"
  admin_username                  = "ratnakar"
  admin_password                  = "India@123456"
  disable_password_authentication = false


  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    name    = "myosdisk1"
    caching = "ReadWrite"
    #create_option     = "FromImage"
    storage_account_type = "Standard_LRS"

  }
  tags = {
    environment = "staging"
  }
}

# os_profile_linux_config {
#   disable_password_authetication = false
#  admin_password = 
#}
data "azurerm_public_ip" "jenkins-terraform-test-publicip" {
  name                = azurerm_public_ip.jenkins-terraform-test-publicip.name
  resource_group_name = azurerm_resource_group.jenkins-terraform-test.name
}

output "public_ip_address" {
  value = data.azurerm_public_ip.jenkins-terraform-test-publicip.ip_address
}
