# ------------------ Outputs for Policy Remediation Module ------------------
# Output remediation resource IDs for reference in root module or other modules.

output "management_group_remediation_ids" {
  description = "IDs of management group remediations."
  value = { for k, v in azurerm_management_group_policy_remediation.this : k => v.id }
}

output "subscription_remediation_ids" {
  description = "IDs of subscription remediations."
  value = { for k, v in azurerm_subscription_policy_remediation.this : k => v.id }
}

output "resource_group_remediation_ids" {
  description = "IDs of resource group remediations."
  value = { for k, v in azurerm_resource_group_policy_remediation.this : k => v.id }
}

output "resource_remediation_ids" {
  description = "IDs of resource remediations."
  value = { for k, v in azurerm_resource_policy_remediation.this : k => v.id }
}
