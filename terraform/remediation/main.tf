# ==================== REMEDIATION MAIN CONFIGURATION ====================
# This file references the remediation module
# Symlinks to: ../../policy_remediation.tf

# Import remediation module from parent directory
# terraform init -backend-config="key=remediation.tfstate"

# The actual module "policy_remediation" block from policy_remediation.tf should be included here
# This will be executed in the remediation directory context

# Remote state reference to policy deployment for dependency tracking
data "terraform_remote_state" "policy_deployment" {
  backend = "azurerm"
  config = {
    resource_group_name  = "myRg1"
    storage_account_name = "teststaccn022002testing"
    container_name       = "tfstate"
    key                  = "policy_deployment.tfstate"
  }
}

# Local reference to policy assignment IDs from the policy deployment state
locals {
  policy_assignment_ids = try(data.terraform_remote_state.policy_deployment.outputs.policy_assignment_ids, {})
}

output "policy_deployment_state_timestamp" {
  description = "Timestamp from policy deployment state for validation"
  value       = try(data.terraform_remote_state.policy_deployment.outputs.policy_assignment_ids != null ? "Policy state available" : "Policy state not found", "Policy state not found")
}
