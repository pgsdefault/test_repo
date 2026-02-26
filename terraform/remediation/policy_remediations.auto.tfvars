# management_group_remediations = [
#   {
#     name = "mgmt-remediate"
#     management_group_id = "/providers/Microsoft.Management/managementGroups/my-mgmt-group"
#     policy_assignment_id = "/providers/Microsoft.Management/managementGroups/my-mgmt-group/providers/Microsoft.Authorization/policyAssignments/my-mgmt-assignment"
#     policy_definition_reference_id = "1234567890123456789"
#     location_filters = ["eastus"]
#     failure_percentage = 0.1
#     parallel_deployments = 5
#     resource_count = 100
#   }
# ]

# subscription_remediations = [
#   {
#     name = "sub-remediate"
#     subscription_id = "4fb4560b-49e0-44b7-8192-3bef773c226c"
#     policy_assignment_id = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c/providers/Microsoft.Authorization/policyAssignments/compute-initiative-assignment"
#     policy_definition_reference_id = "4177495862469218425"
#     location_filters = ["eastus"]
#     failure_percentage = 0.1
#     parallel_deployments = 5
#     resource_count = 100
#   }
# ]

resource_group_remediations = [
  {
    name = "resourcegroup-remediate"
    resource_group_id = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c/resourceGroups/myRg1"
    policy_assignment_id = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c/resourcegroups/myRg1/providers/microsoft.authorization/policyassignments/publicnetworkaccess-initiative-assignment-rg"
    policy_definition_reference_id = "0"
    location_filters = ["South Central US"]
    failure_percentage = 0.1
    parallel_deployments = 5
    resource_count = 100
  }
  # ,
  # {
  #   name = "resourcegroup-remediate-02"
  #   resource_group_id = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c/resourceGroups/myRg1"
  #   policy_assignment_id = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c/resourcegroups/myrg1/providers/microsoft.authorization/policyassignments/encryptionatrest-initiative-assignment-rg"
  #   policy_definition_reference_id = "1"
  #   location_filters = ["South Central US"]
  #   failure_percentage = 0.1
  #   parallel_deployments = 5
  #   resource_count = 100
  # }
]

# resource_remediations = [
#   {
#     name = "resource-remediate"
#     resource_id = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c/resourceGroups/myrg1/providers/Microsoft.Storage/storageAccounts/teststaccn022002testing/blobServices/default"
#     policy_assignment_id = "/subscriptions/4fb4560b-49e0-44b7-8192-3bef773c226c/resourcegroups/myrg1/providers/microsoft.authorization/policyassignments/storage-initiative-assignment-rg"
#     policy_definition_reference_id = "9954422174828580849"
#     location_filters = ["southcentralus"]
#     failure_percentage = 0.1
#     parallel_deployments = 5
#     resource_count = 100
#   }
# ]
