terraform {
  backend "azurerm" {
    resource_group_name  = "Sk_testing"
    storage_account_name = "sa01010101"
    container_name       = "tfstate"
    key                  = "test_deployment.tfstate"  # Separate state file for policy deployment
  }
}
