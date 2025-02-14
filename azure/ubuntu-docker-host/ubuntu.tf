
## Create Public IPs for Ubuntu VM(S)
resource "azurerm_public_ip" "main" {
  count               = local.ubuntu_docker_count
  name                = format("%s-%02d-ubuntu-pub", var.resource_group, count.index + 1)
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

# Create network interface for Ubuntu VM(S)
resource "azurerm_network_interface" "ubuntu_nic" {
  count               = local.ubuntu_docker_count
  name                = format("%s-%02d-ubuntu-nic", var.resource_group, count.index + 1)
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

ip_configuration {
    name                          = "docker-host"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "ubuntu" {
  count                     = local.ubuntu_docker_count
  network_interface_id      = azurerm_network_interface.ubuntu_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.main.id
  depends_on = [azurerm_network_interface.ubuntu_nic]
}

# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.main.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "my_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_linux_virtual_machine" "ubuntu" {
  count               = local.ubuntu_docker_count
  name                  = format("ubuntu-%s-%02d", var.resource_group, count.index + 1)
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.ubuntu_nic[count.index].id,]
  size                  = var.instance
  depends_on = [azurerm_network_interface.ubuntu_nic]

  os_disk {
    name                 = format("ubuntu-osdisk-%02d", count.index + 1)
    caching              = "ReadWrite"
    disk_size_gb         = 256
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    ## Can be searched with: az vm image list --publisher Canonical --all | grep -i ubuntu | grep -i server 
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  computer_name  = format("ubuntu-%02d", count.index + 1)
  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.public_ssh_key
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }
    custom_data = base64encode(<<CLOUD_INIT
#cloud-config
write_files:
  - path: /var/tmp/custom-config.sh
    permissions: 0755
    owner: root:root
    content: |
     #!/bin/bash
     sudo apt update


runcmd:
  # NOTE: Commands must be non-blocking so send long running commands (polling/waiting for mcpd) to the background
  - /var/tmp/custom-config.sh &

CLOUD_INIT
)


}
