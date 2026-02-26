locals {
  policy_json = jsondecode(file(var.policy_json_path))
  has_parameters = length(keys(local.policy_json.parameters)) > 0
}

resource "azurerm_policy_definition" "with_params" {
  count        = local.has_parameters ? 1 : 0
  name         = local.policy_json.name
  display_name = local.policy_json.displayName
  description  = local.policy_json.description
  policy_type  = local.policy_json.policyType
  mode         = local.policy_json.mode
  metadata     = jsonencode(local.policy_json.metadata)
  parameters   = jsonencode(local.policy_json.parameters)
  policy_rule  = jsonencode(local.policy_json.policyRule)
  management_group_id = var.management_group_id != "" ? var.management_group_id : null
}

resource "azurerm_policy_definition" "without_params" {
  count        = local.has_parameters ? 0 : 1
  name         = local.policy_json.name
  display_name = local.policy_json.displayName
  description  = local.policy_json.description
  policy_type  = local.policy_json.policyType
  mode         = local.policy_json.mode
  metadata     = jsonencode(local.policy_json.metadata)
  policy_rule  = jsonencode(local.policy_json.policyRule)
  management_group_id = var.management_group_id != "" ? var.management_group_id : null
}