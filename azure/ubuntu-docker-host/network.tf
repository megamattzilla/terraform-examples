resource "azurerm_virtual_network" "main" {
  name                = "ubuntu-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "docker-host"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.10.10.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                 = "docker-host"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

### INBOUND RULES ###
resource "azurerm_network_security_rule" "mgmt-mgmt_allow_admin" {
  name                        = "mgmt_allow_admin"
  description                 = "Allow Admin access to Ubuntu docker host"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefixes     = var.admin_source_networks
  destination_port_range      = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}