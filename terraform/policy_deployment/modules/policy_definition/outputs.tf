# ---------------------------
# Outputs for Policy Definition Module
# ---------------------------

output "policy_definition_id" {
  value = coalesce(
    try(azurerm_policy_definition.with_params[0].id, null),
    try(azurerm_policy_definition.without_params[0].id, null)
  )
}
