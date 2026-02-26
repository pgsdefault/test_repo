terraform {
  backend "azurerm" {
    resource_group_name  = "myRg1"
    storage_account_name = "teststaccn022002testing"
    container_name       = "tfstate"
    key                  = "policy_deployment.tfstate"  # Separate state file for policy deployment
  }
}
