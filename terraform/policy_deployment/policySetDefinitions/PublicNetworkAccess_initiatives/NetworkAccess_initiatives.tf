variable "management_group_id" {
  description = "Optional management group ID for policy definition scope. If not set, policy is created at subscription scope."
  type        = string
  default     = ""
}
locals {
  custom_policy_files = fileset("${path.module}/../../policyDefinitions/PublicNetworkAccess", "*.json")
  raw_policy_parameters = jsondecode(file("${path.module}/../../parameters/PublicNetworkAccess_parameters.json"))
  policy_parameters = {
    for policy_name, params in local.raw_policy_parameters :
    policy_name => {
      for param_name, param_body in params :
      param_name => {
        value = param_body.value
      }
    }
  }
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
      jsondecode(file("${path.module}/../../policyDefinitions/PublicNetworkAccess/${file}")).metadata,
      "custom_policy_mapping",null
    )
  }
}

module "custom_policy" {
  source              = "../../modules/policy_definition"
  for_each            = toset(local.custom_policy_files)
  policy_json_path    = "${path.module}/../../policyDefinitions/PublicNetworkAccess/${each.key}"
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
        name = "App Configuration should disable public network access"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/3d9f5e4c-9947-4579-9539-2a7695fbc187"
        parameter_values = jsonencode(lookup(local.policy_parameters, "App Configuration should disable public network access", {}))
        policy_group_names          = ["Azure_Security_Benchmark_v3.0_NS-2"]
      },
      {
        name = "Azure Key Vault should disable public network access"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/405c5871-3e91-4644-8a63-58e19d68ff5b"
        parameter_values = jsonencode(lookup(local.policy_parameters, "Azure Key Vault should disable public network access", {}))
         policy_group_names          = ["Azure_Security_Benchmark_v3.0_NS-2"]
      },
      {
        name = "Configure storage accounts to disable public network access"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a06d0189-92e8-4dba-b0c4-08d7669fce7d"
        parameter_values = jsonencode(lookup(local.policy_parameters, "Configure storage accounts to disable public network access", {}))
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

output "PublicNetworkAccess_initiative" {
  value = {
    name         = "NetworkAccess-initiative"
    display_name = "123-PublicNetworkAccess Initiative"
    description  = "Initiative for PublicNetworkAccess related policies, including custom and built-in policies."
    policy_definitions = local.policy_definitions
    policy_definition_groups = local.filtered_policy_definition_groups
    metadata = {
      category    = "PublicNetworkAccess"
      created_by  = "Terraform"
      description = "Initiative for PublicNetworkAccess related policies, including custom and built-in policies."
    }
  }
}
