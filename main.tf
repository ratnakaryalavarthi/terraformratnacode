provider "azurerm" {
  features {

  }
}
resource "azurerm_resource_group" "firsrg" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_virtual_network" "k21network" {
  name                = "k21network"
  address_space       = var.address_space
  location            = azurerm_resource_group.firsrg.location
  resource_group_name = azurerm_resource_group.firsrg.name

}
resource "azurerm_subnet" "k21subnet1" {
  name                 = "k21subet1"
  resource_group_name  = azurerm_resource_group.firsrg.name
  virtual_network_name = azurerm_virtual_network.k21network.name
  address_prefixes     = var.address_prefixes
}
resource "azurerm_public_ip" "k21publicip" {
  name                = "mypubliip"
  location            = azurerm_resource_group.firsrg.location
  resource_group_name = azurerm_resource_group.firsrg.name
  allocation_method   = "Dynamic"

}
resource "azurerm_network_interface" "k21nic" {
  name                = "k21nic"
  location            = azurerm_resource_group.firsrg.location
  resource_group_name = azurerm_resource_group.firsrg.name

  ip_configuration {
    name                          = "k21testipconfiguration"
    subnet_id                     = azurerm_subnet.k21subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.k21publicip.id
  }
}
resource "azurerm_linux_virtual_machine" "firstk21vm" {
  name                            = "firstk21vm"
  resource_group_name             = azurerm_resource_group.firsrg.name
  location                        = "eastus"
  network_interface_ids           = [azurerm_network_interface.k21nic.id]
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
