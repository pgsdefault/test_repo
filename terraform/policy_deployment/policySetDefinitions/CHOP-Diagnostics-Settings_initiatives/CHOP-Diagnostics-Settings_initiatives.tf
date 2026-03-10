variable "management_group_id" {
  description = "Optional management group ID for policy definition scope. If not set, policy is created at subscription scope."
  type        = string
  default     = "/providers/Microsoft.Management/managementGroups/0b41911c-2a00-428b-993b-9b7298dad57d"
}
locals {
  custom_policy_files = fileset("${path.module}/../../policyDefinitions/CHOP-Diagnostics-Settings", "*.json")
  policy_parameters = jsondecode(file("${path.module}/../../parameters/CHOP-Diagnostics-Settings.json"))
  # Get all JSON files in the folder
  policy_group_files = fileset("${path.module}/../../compliance_standard", "*.json")
  # Decode all JSON files
  policy_definition_groups = flatten([
    for f in local.policy_group_files : 
    jsondecode(file("${path.module}/../../compliance_standard/${f}"))
  ])
  # Extract group mapping directly from metadata
  custom_policy_group_mapping = {
    for file in local.custom_policy_files : 
    file => lookup(
      jsondecode(file("${path.module}/../../policyDefinitions/CHOP-Diagnostics-Settings/${file}")).metadata,
      "custom_policy_mapping",null
    )
  }
}

module "custom_policy" {
  source              = "../../modules/policy_definition"
  for_each            = toset(local.custom_policy_files)
  policy_json_path    = "${path.module}/../../policyDefinitions/CHOP-Diagnostics-Settings/${each.key}"
  management_group_id = var.management_group_id
  name                = each.key
}

locals {
  policy_definitions = concat(
    [for k, mod in module.custom_policy : {
      policy_definition_id = mod.policy_definition_id
      parameter_values     = jsonencode(lookup(local.policy_parameters, k, {}))
      policy_group_names   = lookup(local.custom_policy_group_mapping, k, [])
    }],
    
    #List of Built-in Policies 
    [
      {
        name = "Enable logging by category group for Virtual networks (microsoft.network/virtualnetworks) to Log Analytics"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/3234ff41-8bec-40a3-b5cb-109c95f1c8ce"
        parameter_values = jsonencode(lookup(local.policy_parameters, "Enable logging by category group for Virtual networks (microsoft.network/virtualnetworks) to Log Analytics", {}))
        policy_group_names          = []
      },
      {
        name = "Enable logging by category group for Recovery Services vaults (microsoft.recoveryservices/vaults) to Log Analytics"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2f4d1c08-3695-41a7-a0a0-8db4a0e25233"
        parameter_values = jsonencode(lookup(local.policy_parameters, "Enable logging by category group for Recovery Services vaults (microsoft.recoveryservices/vaults) to Log Analytics", {}))
        policy_group_names          = []
      },
        {
        name = "Enable logging by category group for Load balancers (microsoft.network/loadbalancers) to Log Analytics"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/889bfebf-7428-426e-a86f-79e2a7de2f71"
        parameter_values = jsonencode(lookup(local.policy_parameters, "Enable logging by category group for Load balancers (microsoft.network/loadbalancers) to Log Analytics", {}))
        policy_group_names          = []
      },
      {
        name = "Enable logging by category group for Public IP addresses (microsoft.network/publicipaddresses) to Log Analytics"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1513498c-3091-461a-b321-e9b433218d28"
        parameter_values = jsonencode(lookup(local.policy_parameters, "Enable logging by category group for Public IP addresses (microsoft.network/publicipaddresses) to Log Analytics", {}))
        policy_group_names          = []
      },
      {
        name = "Enable logging by category group for Automation Accounts (microsoft.automation/automationaccounts) to Log Analytics"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b797045a-b3cd-46e4-adc4-bbadb3381d78"
        parameter_values = jsonencode(lookup(local.policy_parameters, "Enable logging by category group for Automation Accounts (microsoft.automation/automationaccounts) to Log Analytics", {}))
        policy_group_names          = []
      },
      {
        name = "Enable logging by category group for Virtual network gateways (microsoft.network/virtualnetworkgateways) to Log Analytics"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ed6ae75a-828f-4fea-88fd-dead1145f1dd"
        parameter_values = jsonencode(lookup(local.policy_parameters, "Enable logging by category group for Virtual network gateways (microsoft.network/virtualnetworkgateways) to Log Analytics", {}))
        policy_group_names          = []
      }
    ]
  )
}
// ------------------------------------------------------------
// Dynamic filtering of policy groups used in the initiative
// ------------------------------------------------------------
locals {
  custom_groups_used = flatten([for g in values(local.custom_policy_group_mapping) : g])
  builtin_groups_used = flatten([for p in local.policy_definitions : lookup(p, "policy_group_names", [])])
  all_groups_used = distinct(concat(local.custom_groups_used, local.builtin_groups_used))
  filtered_policy_definition_groups = [
    for g in local.policy_definition_groups : {
      name        = g.name
      display_name=g.display_name
      description = g.description
      category = g.category
    } if contains(local.all_groups_used, g.name)
  ]
}

output "Diagnostics_initiative" {
  value = {
    name         = "CHOP-Diagnostics-Settings-initiative"
    display_name = "CHOP-Diagnostics Settings Initiative"
    description  = "Initiative for CHOP-Diagnostics Settings resources, including custom and built-in policies."
    policy_definitions = local.policy_definitions
    policy_definition_groups = local.filtered_policy_definition_groups
    metadata = {
      category    = "CHOP-Diagnostics Settings"
      created_by  = "Terraform"
      description = "Initiative for CHOP-Diagnostics Settings resources, including custom and built-in policies."
    }
  }
}