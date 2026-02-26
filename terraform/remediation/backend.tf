terraform {
  backend "azurerm" {
    resource_group_name  = "myRg1"
    storage_account_name = "teststaccn022002testing"
    container_name       = "tfstate"
    key                  = "remediation.tfstate"  # Separate state file for remediation
  }
}
