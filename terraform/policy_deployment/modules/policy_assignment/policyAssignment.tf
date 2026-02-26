locals {}

resource "azurerm_subscription_policy_assignment" "this" {
  for_each = { for k, v in var.assignments : k => v if can(regex("^/subscriptions/[a-zA-Z0-9-]+$", v.scope)) }
  name                 = each.value.name
  subscription_id      = each.value.scope
  policy_definition_id = each.value.policy_definition_id
  parameters           = each.value.parameters
  description          = each.value.description
  metadata             = jsonencode({ assignedBy = each.value.assigned_by })
  location             = each.value.location
  not_scopes           = each.value.exclusions

  dynamic "identity" {
    for_each = each.value.policy_definition_id != null ? [1] : []
    content {
      type         = each.value.user_assigned_identity_id != null ? "UserAssigned" : "SystemAssigned"
      identity_ids = each.value.user_assigned_identity_id != null ? [each.value.user_assigned_identity_id] : null
    }
  }
}

resource "azurerm_management_group_policy_assignment" "this" {
  for_each = { for k, v in var.assignments : k => v if can(regex("^/providers/Microsoft.Management/managementGroups/", v.scope)) }
  name                 = each.value.name
  # name                 = length(each.value.name) > 24 ? substr(each.value.name, 0, 24) : each.value.name
  management_group_id  = each.value.scope
  policy_definition_id = each.value.policy_definition_id
  parameters           = each.value.parameters
  description          = each.value.description
  metadata             = jsonencode({ assignedBy = each.value.assigned_by })
  location             = each.value.location
  not_scopes           = each.value.exclusions

  dynamic "identity" {
    for_each = each.value.policy_definition_id != null ? [1] : []
    content {
      type         = each.value.user_assigned_identity_id != null ? "UserAssigned" : "SystemAssigned"
      identity_ids = each.value.user_assigned_identity_id != null ? [each.value.user_assigned_identity_id] : null
    }
  }
}

resource "azurerm_resource_group_policy_assignment" "this" {
  for_each = { for k, v in var.assignments : k => v if can(regex("^/subscriptions/[a-zA-Z0-9-]+/resourceGroups/[a-zA-Z0-9-_\\.]+$", v.scope)) }
  name                 = each.value.name
  resource_group_id    = each.value.scope
  policy_definition_id = each.value.policy_definition_id
  parameters           = each.value.parameters
  description          = each.value.description
  metadata             = jsonencode({ assignedBy = each.value.assigned_by })
  location             = each.value.location
  not_scopes           = each.value.exclusions

  dynamic "identity" {
    for_each = each.value.policy_definition_id != null ? [1] : []
    content {
      type         = each.value.user_assigned_identity_id != null ? "UserAssigned" : "SystemAssigned"
      identity_ids = each.value.user_assigned_identity_id != null ? [each.value.user_assigned_identity_id] : null
    }
  }
}