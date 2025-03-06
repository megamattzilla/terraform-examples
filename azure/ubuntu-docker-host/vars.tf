## Example workspace name:
## terraform workspace create jsmith-westus2-A
locals {
    resource_group        = format("%s-%s-%s", local.prefix_name, local.azure_region,local.release)
    prefix_name           = split("-", terraform.workspace)[0]
    azure_region          = split("-", terraform.workspace)[1]
    release               = split("-", terraform.workspace)[2]          
}

## Any sensitive variables can be declared as environment variables with prefix TF_VAR_
## Example:
##$ export TF_VAR_subscription="subscription ID"

variable "ubuntu_docker_count" {
  ## Number of ubuntu hosts to deploy in this workspace
  default = "1"
}

variable "subscription" {
  ## Obtain subscription ID in output of `az login` 
  default = "subscription-id-here"
}

variable "instance" {
  ## Name of Azure compute instance type. Can search with: az vm list-skus --location southcentralus --output table
  ## Common Examples: Standard_
  default = "Standard_NV12s_v3"
}

variable "admin_username" {
  ## Admin username to be created on Ubuntu VM.
  ## If you change this, also change any reference to this user in ./scripts/ folder.  
  default ="azureuser"
}

variable "public_ssh_key" {
  ## Public SSH key contents to install in ubuntu VMs. Will be used to login after creation. 
  default ="SSH Pub Key Here"
}

variable "admin_source_networks" {
  ## Source networks to permit access to Ubuntu public IPs. 
  default = ["your_source_ip/32", "your_source_ip_2/32"]
}

variable "cloud_init_path" {
  ## Default cloud init onboarding file. Can be overridden per-workspace.  
  default = "./scripts/cloud_init_docker_nvidia.yaml"
}