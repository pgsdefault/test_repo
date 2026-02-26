# ---------------------------
# Outputs for Policy Assignment Module
# ---------------------------

# (No outputs defined in original main.tf)
# Optional: expose only IDs
# output "policy_assignments_id" {
#   description = "All policy assignments created by this module"
#   value = coalesce(
#     try(azurerm_management_group_policy_assignment.this, {}),
#     try( azurerm_subscription_policy_assignment.this, {}),
#     try(azurerm_resource_group_policy_assignment.this, {})   
#   )
# }
output "policy_assignment_ids" {
  description = "Policy assignment IDs created by this module"

  value = merge(
    { for k, v in azurerm_resource_group_policy_assignment.this : k => v.id },
    { for k, v in azurerm_subscription_policy_assignment.this : k => v.id },
    { for k, v in azurerm_management_group_policy_assignment.this : k => v.id }
  )
}
