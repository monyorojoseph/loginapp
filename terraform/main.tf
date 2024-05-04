resource "azurerm_resource_group" "rg" {
  name     = "beeline-swarm-rg"
  location = "southafricanorth"
}

# vnet
resource "azurerm_virtual_network" "vnet" {
  name                = "beeline-swarm-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}


resource "azurerm_subnet" "subnet" {
  name                 = "beeline-swarm-subnet"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# NSGs
resource "azurerm_network_security_group" "nsg" {
  name                = "beeline-swarm-subnet-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# NSG rules
resource "azurerm_network_security_rule" "ssh" {
  name                        = "ssh"
  access                      = "Allow"
  priority                    = 300
  direction                   = "Inbound"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "http" {
  name                        = "http"
  access                      = "Allow"
  priority                    = 310
  direction                   = "Inbound"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "https" {
  name                        = "https"
  access                      = "Allow"
  priority                    = 320
  direction                   = "Inbound"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# docker swarm nsg
resource "azurerm_network_security_rule" "manager_nodes_in_bound" {
  name                        = "ManagerNodesInBound"
  access                      = "Allow"
  priority                    = 330
  direction                   = "Inbound"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "2377"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "overlay_network_node_discovery_in_bound" {
  name                        = "OverlayNetworkNodeDiscoveryInBound"
  access                      = "Allow"
  priority                    = 340
  direction                   = "Inbound"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "7946"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}


resource "azurerm_network_security_rule" "overlay_network_traffic_in_bound" {
  name                        = "OverlayMetworkTrafficInBound"
  access                      = "Allow"
  priority                    = 350
  direction                   = "Inbound"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "4789"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}


resource "azurerm_network_security_rule" "manager_nodes_out_bound" {
  name                        = "ManagerNodesOutBound"
  access                      = "Allow"
  priority                    = 360
  direction                   = "Outbound"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "2377"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "overlay_network_node_discovery_out_bound" {
  name                        = "OverlayNetworkNodeDiscoveryOutbound"
  access                      = "Allow"
  priority                    = 370
  direction                   = "Outbound"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "7946"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}


resource "azurerm_network_security_rule" "overlay_network_traffic_out_bound" {
  name                        = "OverlayMetworkTrafficOutbound"
  access                      = "Allow"
  priority                    = 380
  direction                   = "Outbound"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "4789"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# VMs -> modules
module "vm-01" {
  source              = "./modules/vm_linux"
  vm_name             = "admin-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet.id
}

module "vm-02" {
  source              = "./modules/vm_linux"
  vm_name             = "manager-one-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet.id
}

module "vm-03" {
  source              = "./modules/vm_linux"
  vm_name             = "manager-two-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet.id
}
module "vm-04" {
  source              = "./modules/vm_linux"
  vm_name             = "worker-one-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet.id
}

module "vm-05" {
  source              = "./modules/vm_linux"
  vm_name             = "worker-two-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet.id
}


module "vm-06" {
  source              = "./modules/vm_linux"
  vm_name             = "worker-three-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet.id
}

module "vm-07" {
  source              = "./modules/vm_linux"
  vm_name             = "worker-four-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet.id
}
