# output "exemption_ids" {
#   description = "Policy exemption IDs created by this module"

#   value = merge(
#     { for k, v in azurerm_management_group_policy_exemption.mg : k => v.id },
#     { for k, v in azurerm_subscription_policy_exemption.sub : k => v.id },
#     { for k, v in azurerm_resource_group_policy_exemption.rg : k => v.id }
#   )
# }
output "exemption_ids" {
  description = "Policy exemption IDs created by this module"
  value = merge(
    { for r in azurerm_resource_group_policy_exemption.rg : r.name => r.id },
    { for r in azurerm_subscription_policy_exemption.sub : r.name => r.id },
    { for r in azurerm_management_group_policy_exemption.mg : r.name => r.id }
  )
}
