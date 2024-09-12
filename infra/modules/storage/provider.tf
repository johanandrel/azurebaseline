terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.0.1"
    }
  }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
  subscription_id = "9539bc24-8692-4fe2-871e-3733e84b1b73"
}