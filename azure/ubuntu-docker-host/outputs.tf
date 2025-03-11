locals {
  ips_int         = zipmap(azurerm_linux_virtual_machine.ubuntu[*].name, azurerm_network_interface.ubuntu_nic[*].private_ip_address)
  ips_public      = zipmap(azurerm_linux_virtual_machine.ubuntu[*].name, azurerm_public_ip.main[*].ip_address)
}

output "access_info" {
  value = {
    note = "Deployment complete! Please remember to REBOOT your system for all changes to take effect. To access via ssh run: ssh username@public_ip -i /path/to/ssh/key"
    IP_Addresses = {
      "Internal IP"  = local.ips_int
      "Public IP"  = local.ips_public
    }
    Username = var.admin_username
  }
}