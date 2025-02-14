## Any sensitive variables can be declared as enviorment variables with prefix TF_VAR_
## Example:
##$ export TF_VAR_subscription="subscription ID"

variable "subscription" {
  ## Obtain subscription ID in output of `az login` 
  default = "subscription-id-here"
}

variable "resource_group" {
  ## Name of new Azure RG to place all resources 
  default = "Azure RG Here"
}

variable "azure_region" {
  ## Name of Azure region to place all resources 
  default = "westus2"
}

variable "instance" {
  ## Name of Azure compute instance type. Can search with: az vm list-skus --location southcentralus --output table
  ## Common Examples: Standard_
  default = "Standard_NV12s_v3"
}

variable "admin_username" {
  ## Admin username to be created on Ubuntu VM. 
  default ="azureuser"
}

variable "public_ssh_key" {
  ## Public SSH key contents to install in ubuntu VMs. Will be used to login after creation. 
  default ="SSH Pub Key Here"
}

variable "admin_source_networks" {
  ## Source networks to premit access to Ubuntu public IPs. 
  default = ["192.168.1.0/24, 192.168.2.0/24"]
}

locals {
    ubuntu_docker_count = 1
}

