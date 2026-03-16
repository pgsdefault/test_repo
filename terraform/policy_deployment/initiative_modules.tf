# ------------------ Initiative Creation & Assignment Modules ------------------
# This file combines initiative creation and assignment logic for easier maintenance.
# These blocks rarely change. To add new initiatives/services, update initiative_loader.tf and locals.tf.

module "initiative" {
  for_each                  = local.initiatives
  source                    = "./modules/policy_set_definition"

  name                      = each.value.name
  display_name              = each.value.display_name
  description               = each.value.description
  policy_definitions        = each.value.policy_definitions
  policy_definition_groups  = each.value.policy_definition_groups

  metadata                  = jsonencode(each.value.metadata)

  delete_initiatives        = var.delete_initiatives
  scope_exclusions          = var.scope_exclusions
  management_group_id       = var.management_group_id
}

module "initiative_assignment" {
  source = "./modules/policy_assignment"

  assignments = merge(
    # ---------------- Resource Group Assignment Example ----------------
    # {
    #   for k, v in local.initiative_ids :
    #   "${k}-rg" => {
    #     name                 = "${k}-initiative-assignment-rg"
    #     scope                = "/subscriptions/d1ff6b24-f9e0-4125-addc-70b229cc1330/resourceGroups/Sk_testing"
    #     policy_definition_id = v.policy_set_definition_id
    #     parameters           = ""
    #     description          = v.description
    #     assigned_by          = "Terraform"
    #     location             = "South Central Us"
    #     user_assigned_identity_id = "/subscriptions/d1ff6b24-f9e0-4125-addc-70b229cc1330/resourceGroups/Sk_testing/providers/Microsoft.ManagedIdentity/userAssignedIdentities/UAMI"
    #     exclusions           = lookup(var.policy_exclusions, k, [])
    #   }
    # },

    # ---------------- Subscription Assignment Example ----------------
    # {
    #   for k, v in local.initiative_ids :
    #   "${k}-sub" => {
    #     name                 = "${k}-initiative-assignment-sub"
    #     scope                = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c"
    #     policy_definition_id = v.policy_set_definition_id
    #     parameters           = ""
    #     description          = v.description
    #     assigned_by          = "EPIC Azure Policy Team"
    #     location             = "South Central Us"
    #     user_assigned_identity_id = null
    #     exclusions           = lookup(var.policy_exclusions, k, [])
    #   }
    # },

    # ---------------- Management Group Assignment ----------------
    {
      for k, v in local.initiative_ids :
      "${k}-mg" => {
        name                 = "${k}-assgn"
        scope                = "/providers/Microsoft.Management/managementGroups/mg11"
        policy_definition_id = v.policy_set_definition_id
        parameters           = ""
        description          = v.description
        assigned_by          = "Terraform"
        location             = "South Central Us"

        user_assigned_identity_id = "/subscriptions/d1ff6b24-f9e0-4125-addc-70b229cc1330/resourceGroups/Sk_testing/providers/Microsoft.ManagedIdentity/userAssignedIdentities/ptesting2"

        exclusions = lookup(var.policy_exclusions, k, [])
      }
    }
  )
}

# -------------------------------------------------------------------
# Example Built-in Initiative Assignment (Manual Parameter Editing)
# -------------------------------------------------------------------

# resource "azurerm_subscription_policy_assignment" "monitor_agent_assignment" {
#   name                 = "custom-monitor-agent-assignment"
#   subscription_id      = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c"
#   policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/0d1b56c6-6d1f-4a5d-8695-b15efbea6b49"
#
#   parameters = jsonencode({
#     dcrResourceId = { value = "" }
#     bringYourOwnUserAssignedManagedIdentity = { value = false }
#   })
#
#   description = "Custom assignment for built-in Monitor Agent initiative"
#   location    = "East US"
#
#   identity {
#     type = "SystemAssigned"
#   }
# }

# -------------------------------------------------------------------
# CIS v3 Built-in Initiative Assignment (Management Group Scope)
# -------------------------------------------------------------------

resource "azurerm_management_group_policy_assignment" "cisv3_assignment" {

  name                 = "CHOP-CIS Azure Fdns v3"
  management_group_id  = "/providers/Microsoft.Management/managementGroups/mymg"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/470a962c-86a0-433b-803a-3c176b5ce79c"

  parameters = jsonencode({
    effect-8405fdab-1faf-48aa-b702-999c9c172094 = { value = "Deny" }
    effect-12d4fa5e-1f9f-4c21-97a9-b99b3c6611b5 = { value = "Deny" }
    effect-fe83a0eb-a853-422d-aac2-1bffd182c5d0 = { value = "Deny" }
    effect-404c3081-a854-4457-ae30-26a93ef643f9 = { value = "Deny" }
    effect-4fa4b6c0-31ca-4c0d-b10d-24b96f62a751 = { value = "Deny" }
    effect-34c877ad-507e-4c82-993e-3452a6e0ad3c = { value = "Deny" }
    effect-2a1a9cdf-e04d-429a-8416-3bfb72a1b26f = { value = "Deny" }
  })

  description = "CIS Azure Foundations 3.0 defines benchmark controls to improve cloud security in Microsoft Azure. The standard aligns with industry best practices for risk reduction and secure configurations."
}

# -------------------------------------------------------------------
# Example: CIS Benchmark Initiative Assignment (Resource Group)
# -------------------------------------------------------------------

# resource "azurerm_resource_group_policy_assignment" "cis_benchmark_assignment" {
#   name                 = "custom-cis_benchmark-assignment"
#   resource_group_id    = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c/resourceGroups/myRg1"
#   policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/06f19060-9e68-4070-92ca-f15cc126059e"
#
#   parameters = jsonencode({})
#
#   description = "Custom assignment for built-in CIS Microsoft Azure Foundations Benchmark v2.0.0 initiative"
#   location    = "South Central US"
#
#   identity {
#     type = "SystemAssigned"
#   }
# }