policy_exemptions = [
  # {
  #   name = "mgmt-group-exemption"
  #   scope = "/providers/Microsoft.Management/managementGroups/my-mgmt-group"
  #   policy_assignment_id = "/providers/Microsoft.Management/managementGroups/my-mgmt-group/providers/Microsoft.Authorization/policyAssignments/my-mgmt-assignment"
  #   policy_definition_reference_ids = ["1234567890123456789"]
  #   exemption_category = "Mitigated"
  #   description = "Exempt a policy in management group scope"
  #   expires_on = "2025-08-22T23:59:59Z"
  #   metadata = { owner = "roshan" }
  # },
  # {
  #   name = "subscription-exemption-01"
  #   scope = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c"
  #   policy_assignment_id = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c/providers/microsoft.authorization/policyassignments/storage-initiative-assignment-sub"
  #   policy_definition_reference_ids = ["0","2"]
  #   exemption_category = "Waiver"
  #   description = "Exempt a policy in subscription scope"
  #   expires_on = "2026-01-10T23:59:59Z"
  #   metadata = { owner = "Pushpa" }
  # }
  # ,
  # {
  #   name = "resource-group-exemption"
  #   scope = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c/resourceGroups/Terraform"
  #   policy_assignment_id = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c/resourcegroups/terraform/providers/microsoft.authorization/policyassignments/storage-initiative-assignment-rg"
  #   policy_definition_reference_ids = ["3"]
  #   exemption_category = "Mitigated"
  #   description = "Exempt a policy in resource group scope"
  #   expires_on = "2026-08-22T23:59:59Z"
  #   metadata = { owner = "Pushpa" }
  # }
  {
    name = "resource-group-exemption-02"
    display_name = "Testing Exemption"
    scope = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c/resourceGroups/myRg1"
    policy_assignment_id = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c/resourceGroups/myRg1/providers/microsoft.authorization/policyassignments/publicip-initiative-assignment-rg"
    policy_definition_reference_ids = ["1"]
    exemption_category = "Mitigated"
    description = "Exempt a policy in resource group scope"
    expires_on = "2026-08-22T23:59:59Z"
    metadata = { owner = "Chitra" }
  }
]

