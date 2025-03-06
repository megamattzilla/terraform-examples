# Deploy n-number Ubuntu Docker Hosts in Azure Cloud

## Overview

A terraform workspace name is used as input to the terraform template to specify:
- A prefix for all Azure resources 
- Azure Region 
- Release version



### Requirements:  
- Have a linux machine with terraform installed. 
    - Recommended to install with [tfenv](https://github.com/tfutils/tfenv).
- Active Azure cloud subscription



### Before running terraform
Install Azure CLI https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux 

For Debian/Ubuntu: 
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

Login to Azure API
```bash
az login
#Successful output will contain your subscription ID. This will be used in a later step. 
```

### Clone Repo
```bash
git clone git@github.com:megamattzilla/terraform-examples.git
cd terraform-examples/azure/ubuntu-docker-host
```
### Setup Secrets

Generate new SSH key or use your own:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
#for demo purposes, its easier to skip the key passphrase
```

Set environment variable with your deployment secrets
```bash
export TF_VAR_public_ssh_key="your public SSH Key"   ## Obtain with: cat ~/.ssh/id_ed25519.pub
export TF_VAR_subscription="your Azure subscription ID"   ## Obtain subscription ID in output of `az login` 
```

### Run Terraform

Review variables in `vars.tf` and customize as needed. Update admin_source_networks with your client IP(s).
```bash
ubuntu_docker_count    ## Number of ubuntu hosts to deploy in this workspace
instance               ## Name of Azure compute instance type. Can search with: az vm list-skus --location southcentralus --output table
admin_username         ## Admin username to be created on Ubuntu VM.
public_ssh_key         ## Public SSH key contents to install in ubuntu VMs. Will be used to login after creation.
admin_source_networks  ## Source networks to permit access to Ubuntu public IPs. 
cloud_init_path        ## Default cloud init onboarding file. Can be overridden per-workspace.  
```

Initalize providers
```bash
terraform init
```

Create terraform workspace such as `user-westus2-B`. 
```bash
terraform workspace new user-westus2-B
terraform workspace select user-westus2-B #(If needed)
```

Apply the changes
```bash
terraform apply
#If your apply fails due to Azure resource limits, follow the error message to submit a quota increase. 
#If deploying Azure VE with Nvidia GPU,  Nvidia drivers requires a reboot.  Please reboot after first deploy. 
```

Delete everything:
```bash
terraform destroy
```

### Appendix: (Optional) Customize variables per workspace
You can create a file in `./workspace_vars/` with the name of your workspace ending in .tfvar. 

Example: customize the instance type for workspace `user-westus2-B`:
```bash
touch ./workspace_vars/user-westus2-B.tfvars
echo "instance = "Standard_D8s_v5" > ./workspace_vars/user-westus2-B.tfvars
```

When you run terraform, include a reference to the workspace var file:
```bash
terraform apply  -var-file=workspace_vars/$(terraform workspace show).tfvars
```
