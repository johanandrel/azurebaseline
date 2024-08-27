terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.105.0"
    }
    mssql = {
      source  = "betr-io/mssql"
      version = "0.3.1"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "mssql" {
  debug = "true"
}