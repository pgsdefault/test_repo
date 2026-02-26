# ---------------------------
# Outputs for Policy Set Definition Module
# ---------------------------

output "policy_set_definition_id" {
  value = (
    length(azurerm_management_group_policy_set_definition.this) > 0 ? azurerm_management_group_policy_set_definition.this[0].id : length(azurerm_policy_set_definition.this) > 0 ? azurerm_policy_set_definition.this[0].id : null
  )
}
