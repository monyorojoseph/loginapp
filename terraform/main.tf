# rg
resource "azurerm_resource_group" "rg" {
  name     = "login-app-rg"
  location = "southafricanorth"
}

# vnet
resource "azurerm_virtual_network" "vnet" {
  name                = "login-app-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

# subnet
resource "azurerm_subnet" "subnet" {
  name                 = "login-app-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# nsg
resource "azurerm_network_security_group" "nsg" {
  name                = "login-app-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# association
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# NSG rules
resource "azurerm_network_security_rule" "ssh" {
  for_each               = { for rule in var.inbound_ports : rule.name => rule }
  name                   = each.value.name
  priority               = each.value.priority
  destination_port_range = each.value.port

  access                      = "Allow"
  direction                   = "Inbound"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# pip
resource "azurerm_public_ip" "pip_vm" {
  name                = "login-app-vm-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

# nic
resource "azurerm_network_interface" "nic_vm" {
  name                = "login-app-vm-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_vm.id
  }
}

# vm
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "login-app-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B2ats_v2"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic_vm.id]

  custom_data = filebase64("./init.sh")

  os_disk {
    name                 = "login-app-os-disk-vm"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

}