terraform {
  required_version = ">= 1.6.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.18.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription
  features {}
}
