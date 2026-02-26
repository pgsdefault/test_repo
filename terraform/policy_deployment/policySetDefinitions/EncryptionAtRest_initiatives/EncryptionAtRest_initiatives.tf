variable "management_group_id" {
  description = "Optional management group ID for policy definition scope. If not set, policy is created at subscription scope."
  type        = string
  default     = ""
}
locals {
  custom_policy_files = fileset("${path.module}/../../policyDefinitions/EncryptionAtRest", "*.json")
  raw_policy_parameters = jsondecode(file("${path.module}/../../parameters/EncryptionAtRest_parameters.json"))
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
      jsondecode(file("${path.module}/../../policyDefinitions/EncryptionAtRest/${file}")).metadata,
      "custom_policy_mapping",null
    )
  }
}

module "custom_policy" {
  source              = "../../modules/policy_definition"
  for_each            = toset(local.custom_policy_files)
  policy_json_path    = "${path.module}/../../policyDefinitions/EncryptionAtRest/${each.key}"
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
        name = "Azure Batch account should use customer-managed keys to encrypt data"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/99e9ccd8-3db9-4592-b0d1-14b1715a4d8a"
        parameter_values = jsonencode(lookup(local.policy_parameters, "Azure Batch account should use customer-managed keys to encrypt data", {}))
        policy_group_names          = ["Azure_Security_Benchmark_v3.0_DP-5","NIST_SP_800-53_R5_SC-12"]
      },
      {
        name = "Container registries should be encrypted with a customer-managed key"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/5b9159ae-1701-4a6f-9a7a-aa9c8ddd0580"
        parameter_values = jsonencode(lookup(local.policy_parameters, "Container registries should be encrypted with a customer-managed key", {}))
         policy_group_names          = ["Azure_Security_Benchmark_v3.0_DP-5","NIST_SP_800-53_R5_SC-12"]
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

output "EncryptionAtRest_initiative" {
  value = {
    name         = "EncryptionAtRest-initiative"
    display_name = "123-EncryptionAtRest Initiative"
    description  = "Initiative for EncryptionAtRest policies, including custom and built-in policies."
    policy_definitions = local.policy_definitions
    policy_definition_groups = local.filtered_policy_definition_groups
    metadata = {
      category    = "EncryptionAtRest"
      created_by  = "Terraform"
      description = "Initiative for EncryptionAtRest policies, including custom and built-in policies."
    }
  }
}
