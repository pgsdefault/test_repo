# ------------------ Policy Remediation Module ------------------
# Supports management group, subscription, resource group, and resource scopes.

resource "azurerm_management_group_policy_remediation" "this" {
  for_each = { for r in var.management_group_remediations : r.name => r }
  name                 = each.value.name
  management_group_id  = each.value.management_group_id
  policy_assignment_id = each.value.policy_assignment_id
  policy_definition_reference_id = lookup(each.value, "policy_definition_reference_id", null)
  location_filters     = lookup(each.value, "location_filters", null)
  failure_percentage   = lookup(each.value, "failure_percentage", null)
  parallel_deployments = lookup(each.value, "parallel_deployments", null)
  resource_count       = lookup(each.value, "resource_count", null)
}

resource "azurerm_subscription_policy_remediation" "this" {
  for_each = { for r in var.subscription_remediations : r.name => r }
  name                 = each.value.name
  subscription_id      = each.value.subscription_id
  policy_assignment_id = each.value.policy_assignment_id
  policy_definition_reference_id = lookup(each.value, "policy_definition_reference_id", null)
  location_filters     = lookup(each.value, "location_filters", null)
  failure_percentage   = lookup(each.value, "failure_percentage", null)
  parallel_deployments = lookup(each.value, "parallel_deployments", null)
  resource_count       = lookup(each.value, "resource_count", null)
}

resource "azurerm_resource_group_policy_remediation" "this" {
  for_each = { for r in var.resource_group_remediations : r.name => r }
  name                 = each.value.name
  resource_group_id    = each.value.resource_group_id
  policy_assignment_id = each.value.policy_assignment_id
  policy_definition_reference_id = lookup(each.value, "policy_definition_reference_id", null)
  location_filters     = lookup(each.value, "location_filters", null)
  failure_percentage   = lookup(each.value, "failure_percentage", null)
  parallel_deployments = lookup(each.value, "parallel_deployments", null)
  resource_count       = lookup(each.value, "resource_count", null)
}

resource "azurerm_resource_policy_remediation" "this" {
  for_each = { for r in var.resource_remediations : r.name => r }
  name                 = each.value.name
  resource_id          = each.value.resource_id
  policy_assignment_id = each.value.policy_assignment_id
  policy_definition_reference_id = lookup(each.value, "policy_definition_reference_id", null)
  location_filters     = lookup(each.value, "location_filters", null)
  failure_percentage   = lookup(each.value, "failure_percentage", null)
  parallel_deployments = lookup(each.value, "parallel_deployments", null)
  resource_count       = lookup(each.value, "resource_count", null)
}
