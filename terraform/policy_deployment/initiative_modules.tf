# ------------------ Initiative Creation & Assignment Modules ------------------
# This file combines initiative creation and assignment logic for easier maintenance.
# These blocks rarely change. To add new initiatives/services, update initiative_loader.tf and locals.tf.

module "initiative" {
  for_each           = local.initiatives
  source             = "./modules/policy_set_definition"
  name               = each.value.name
  display_name       = each.value.display_name
  description        = each.value.description
  policy_definitions = each.value.policy_definitions
  metadata           = jsonencode(each.value.metadata)
  delete_initiatives = var.delete_initiatives
  scope_exclusions   = var.scope_exclusions
  management_group_id = var.management_group_id
  policy_definition_groups  = each.value.policy_definition_groups
}

module "initiative_assignment" {
  source     = "./modules/policy_assignment"
  assignments = merge(
    {
      for k, v in local.initiative_ids :
      "${k}-rg" => {
        name                      = "${k}-initiative-assignment-rg"
        scope                     = "/subscriptions/d1ff6b24-f9e0-4125-addc-70b229cc1330/resourceGroups/Sk_testing"
        policy_definition_id      = v.policy_set_definition_id
        parameters                = ""
        description               = v.description
        #assigned_by               = data.azuread_user.current.user_principal_name
        assigned_by               = "Terraform"
        location                  = "South Central Us"
        user_assigned_identity_id = "/subscriptions/d1ff6b24-f9e0-4125-addc-70b229cc1330/resourceGroups/Sk_testing/providers/Microsoft.ManagedIdentity/userAssignedIdentities/UAMI"
        exclusions                = lookup(var.policy_exclusions, k, [])
      }
    }
    # ,
    # {
    #   for k, v in local.initiative_ids :
    #   "${k}-sub" => {
    #     name                      = "${k}-initiative-assignment-sub"
    #     scope                     = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c"
    #     policy_definition_id      = v.policy_set_definition_id
    #     parameters                = ""
    #     description               = v.description
    #     #assigned_by               = data.azuread_user.current.user_principal_name
    #     assigned_by               = "EPIC Azure Policy Team"
    #     location                  = "South Central Us"
    #     user_assigned_identity_id = null
    #     exclusions                = lookup(var.policy_exclusions, k, [])
    #   }
    # }
    # ,
    # {
    #   for k, v in local.initiative_ids :
    #   "${k}-mg" => {
    #     name                      = "${k}-initiative-assignment-mg"
    #     scope                     = "/providers/Microsoft.Management/managementGroups/Azure-mg-1"
    #     policy_definition_id      = v.policy_set_definition_id
    #     parameters                = ""
    #     description               = v.description
    #     # assigned_by               = data.azuread_user.current.user_principal_name
    #     assigned_by               = "Terraform"
    #     location                  = "South Central Us"
    #     user_assigned_identity_id = null
    #     exclusions                = lookup(var.policy_exclusions, k, [])
    #   }
    # }
  )
}

# Example: Built-in initiative assignment block for manual parameter editing
# resource "azurerm_subscription_policy_assignment" "monitor_agent_assignment" {
#   name                 = "custom-monitor-agent-assignment"
#   subscription_id   = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c"
#   policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/0d1b56c6-6d1f-4a5d-8695-b15efbea6b49"
#   parameters           = jsonencode({
#     dcrResourceId = { value = "" }
#     bringYourOwnUserAssignedManagedIdentity = { value = false }
#     # Add other required parameters if needed
#   })
#   description          = "Custom assignment for built-in Monitor Agent initiative"
#   location             = "East US"

#   identity {
#     type         = "SystemAssigned"
#     # identity_ids = ["<your-user-assigned-identity-resource-id>"]
#   }
# }

# resource "azurerm_subscription_policy_assignment" "nist_assignment" {
#   name                 = "custom-NIST-assignment"
#   subscription_id   = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c"
#   policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/179d1daa-458f-4e47-8086-2a68d0d6c38f"
#   parameters           = jsonencode({
    
#   })
#   description          = "Custom assignment for built-in NIST initiative"
#   location             = "East US"

#   identity {
#     type         = "SystemAssigned"
#     # identity_ids = ["<your-user-assigned-identity-resource-id>"]
#   }
# }
# resource "azurerm_resource_group_policy_assignment" "mcsb_assignment" {
#   name                 = "custom-mcsb-assignment"
#   resource_group_id    = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c/resourceGroups/policytest1-rg"
#   policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"
#   parameters           = jsonencode({
#     # dcrResourceId = { value = "" }
#     # bringYourOwnUserAssignedManagedIdentity = { value = false }
#     # Add other required parameters if needed
#   })
#   description          = "Custom assignment for built-in MCSB initiative"
#   location             = "East US"

#   identity {
#     type         = "SystemAssigned"
#     # identity_ids = ["<your-user-assigned-identity-resource-id>"]
#   }
# }
#We can do at given scope
# resource "azurerm_management_group_policy_assignment" "mcsb_assignment" {
#   name                 = "custom-mcsb-assignment"
#   management_group_id  = "/providers/Microsoft.Management/managementGroups/Azure-mg-1"
#   policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"
#   parameters           = jsonencode({
#     # dcrResourceId = { value = "" }
#     # bringYourOwnUserAssignedManagedIdentity = { value = false }
#     # Add other required parameters if needed
#   })
#   description          = "Custom assignment for built-in MCSB initiative"
#   location             = "East US"

#   identity {
#     type         = "SystemAssigned"
#     # identity_ids = ["<your-user-assigned-identity-resource-id>"]
#   }
# }


# resource "azurerm_resource_group_policy_assignment" "CIS_Benchmark_assignment" {
#   name                 = "custom-cis_benchmark-assignment"
#   resource_group_id    = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c/resourceGroups/myRg1"
#   policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/06f19060-9e68-4070-92ca-f15cc126059e"
#   parameters           = jsonencode({
#     # dcrResourceId = { value = "" }
#     # bringYourOwnUserAssignedManagedIdentity = { value = false }
#     # Add other required parameters if needed
#   })
#   description          = "Custom assignment for built-in CIS Microsoft Azure Foundations Benchmark v2.0.0 initiative"
#   location             = "South Central us"

#   identity {
#     type         = "SystemAssigned"
#     # identity_ids = ["<your-user-assigned-identity-resource-id>"]
#   }
# }