terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }

  backend "azurerm" {
      resource_group_name  = "school2022"
      storage_account_name = "school2022endava"
      container_name       = "schoolvhds"
      key                  = "terraform.tfstate"
  }

}

provider "azurerm" {
  features {}
}
