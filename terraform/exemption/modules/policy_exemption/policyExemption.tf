
resource "azurerm_management_group_policy_exemption" "mg" {
  count = can(regex("^/providers/Microsoft.Management/managementGroups/", var.scope)) ? 1 : 0
  name                 = var.name
  display_name         = var.display_name
  management_group_id  = var.scope
  policy_assignment_id = var.policy_assignment_id
  policy_definition_reference_ids = var.policy_definition_reference_ids
  exemption_category   = var.exemption_category
  description          = var.description
  expires_on           = var.expires_on
  metadata             = var.metadata != null ? jsonencode(var.metadata) : null
}

resource "azurerm_subscription_policy_exemption" "sub" {
  count = can(regex("^/subscriptions/", var.scope)) && !can(regex("/resourceGroups/", var.scope)) ? 1 : 0
  name                 = var.name
  display_name         = var.display_name
  subscription_id      = var.scope
  policy_assignment_id = var.policy_assignment_id
  policy_definition_reference_ids = var.policy_definition_reference_ids
  exemption_category   = var.exemption_category
  description          = var.description
  expires_on           = var.expires_on
  metadata             = var.metadata != null ? jsonencode(var.metadata) : null
}

resource "azurerm_resource_group_policy_exemption" "rg" {
  count = can(regex("/resourceGroups/", var.scope)) ? 1 : 0
  name                 = var.name
  display_name         = var.display_name
  resource_group_id    = var.scope
  policy_assignment_id = var.policy_assignment_id
  policy_definition_reference_ids = var.policy_definition_reference_ids
  exemption_category   = var.exemption_category
  description          = var.description
  expires_on           = var.expires_on
  metadata             = var.metadata != null ? jsonencode(var.metadata) : null
}
