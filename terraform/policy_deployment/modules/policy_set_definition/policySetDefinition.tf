# Subscription-scope initiative
resource "azurerm_policy_set_definition" "this" {
  count        = (lookup(var.delete_initiatives, var.name, false) ? 0 : (var.management_group_id == "" ? 1 : 0))
  name         = var.name
  policy_type  = var.policy_type
  display_name = var.display_name
  metadata     = var.metadata
  description  = var.description


 dynamic "policy_definition_group" {
  for_each = var.policy_definition_groups

  content {
    name         = policy_definition_group.value.name
    display_name = policy_definition_group.value.display_name
    description  = lookup(policy_definition_group.value, "description", null)
    category     = lookup(policy_definition_group.value, "category", null)
  }
}

  dynamic "policy_definition_reference" {
    for_each = var.policy_definitions
    content {
      policy_definition_id = policy_definition_reference.value.policy_definition_id
      reference_id = policy_definition_reference.key
      parameter_values     = policy_definition_reference.value.parameter_values
      policy_group_names   = lookup(policy_definition_reference.value, "policy_group_names", null)
    }
  }
}

# Management-group-scope initiative
resource "azurerm_management_group_policy_set_definition" "this" {
  count               = (lookup(var.delete_initiatives, var.name, false) ? 0 : (var.management_group_id != "" ? 1 : 0))
  name                = var.name
  policy_type         = var.policy_type
  display_name        = var.display_name
  metadata            = var.metadata
  description         = var.description
  management_group_id = var.management_group_id


dynamic "policy_definition_group" {
    for_each = var.policy_definition_groups 
    content {
      name         = policy_definition_group.value.name
      display_name = policy_definition_group.value.display_name
      description  = policy_definition_group.value.description
      category     = policy_definition_group.value.category
    }
  }

  dynamic "policy_definition_reference" {
    for_each = var.policy_definitions
    content {
      policy_definition_id = policy_definition_reference.value.policy_definition_id
      reference_id = policy_definition_reference.key
      parameter_values     = policy_definition_reference.value.parameter_values
      policy_group_names   = lookup(policy_definition_reference.value, "policy_group_names", null)
    }
  }
}
