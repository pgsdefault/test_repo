variable "management_group_id" {
  description = "Optional management group ID for policy definition scope. If not set, policy is created at subscription scope."
  type        = string
  default     = ""
}
locals {
  custom_policy_files = fileset("${path.module}/../../policyDefinitions/ZeroTrust", "*.json")
  raw_policy_parameters = jsondecode(file("${path.module}/../../parameters/ZeroTrust_parameters.json"))
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
      jsondecode(file("${path.module}/../../policyDefinitions/ZeroTrust/${file}")).metadata,
      "custom_policy_mapping",null
    )
  }
}

module "custom_policy" {
  source              = "../../modules/policy_definition"
  for_each            = toset(local.custom_policy_files)
  policy_json_path    = "${path.module}/../../policyDefinitions/ZeroTrust/${each.key}"
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
        name = "Azure Key Vault should use RBAC permission model"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/12d4fa5e-1f9f-4c21-97a9-b99b3c6611b5"
        parameter_values = jsonencode(lookup(local.policy_parameters, "Azure Key Vault should use RBAC permission model", {}))
        policy_group_names          = ["CIS_Azure_2.0.0_8.6"]
      },
      {
        name = "App Configuration stores should have local authentication methods disabled"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b08ab3ca-1062-4db3-8803-eec9cae605d6"
        parameter_values = jsonencode(lookup(local.policy_parameters, "App Configuration stores should have local authentication methods disabled", {}))
         policy_group_names          = []
      },
      {
        name = "Users must authenticate with multi-factor authentication to create or update resources"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/4e6c27d5-a6ee-49cf-b2b4-d8fe90fa2b8b"
        parameter_values = jsonencode(lookup(local.policy_parameters, "Users must authenticate with multi-factor authentication to create or update resources", {}))
         policy_group_names          = ["Azure_Security_Benchmark_v3.0_IM-2"]
      },
      {
        name = "Configure App Configuration stores to disable local authentication methods"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/72bc14af-4ab8-43af-b4e4-38e7983f9a1f"
        parameter_values = jsonencode(lookup(local.policy_parameters, "Configure App Configuration stores to disable local authentication methods", {}))
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

output "ZeroTrust_initiative" {
  value = {
    name         = "ZeroTrust-initiative"
    display_name = "123-Zero Trust Initiative"
    description  = "Initiative for zero trust model, including custom and built-in policies."
    policy_definitions = local.policy_definitions
    policy_definition_groups = local.filtered_policy_definition_groups
    metadata = {
      category    = "Zero Trust"
      created_by  = "Terraform"
      description = "Initiative for Zero Trust principal policies, including custom and built-in policies."
    }
  }
}
