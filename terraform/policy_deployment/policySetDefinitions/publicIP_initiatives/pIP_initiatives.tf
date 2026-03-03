variable "management_group_id" {
  description = "Optional management group ID for policy definition scope. If not set, policy is created at subscription scope."
  type        = string
  default     = ""
}
locals {
  custom_policy_files = fileset("${path.module}/../../policyDefinitions/publicIP", "*.json")
  raw_policy_parameters = jsondecode(file("${path.module}/../../parameters/publicIP_parameters.json"))
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
      jsondecode(file("${path.module}/../../policyDefinitions/publicIP/${file}")).metadata,
      "custom_policy_mapping",null
    )
  }
}

module "custom_policy" {
  source              = "../../modules/policy_definition"
  for_each            = toset(local.custom_policy_files)
  policy_json_path    = "${path.module}/../../policyDefinitions/publicIP/${each.key}"
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
        name = "Network interfaces should not have public IPs"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114"
        parameter_values = jsonencode(lookup(local.policy_parameters, "Network interfaces should not have public IPs", {}))
        policy_group_names          = []
      },
      {
        name = "Configure App Service app slots to use the latest TLS version"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/014664e7-e348-41a3-aeb9-566e4ff6a9df"
        parameter_values = jsonencode(lookup(local.policy_parameters, "Configure App Service app slots to use the latest TLS version", {}))
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

output "publicIP_initiative" {
  value = {
    name         = "pIP-initiative"
    display_name = "123-publicIP Initiative"
    description  = "Initiative for publicIP related policies, including custom and built-in policies."
    policy_definitions = local.policy_definitions
    policy_definition_groups = local.filtered_policy_definition_groups
    metadata = {
      category    = "publicIP"
      created_by  = "Terraform"
      description = "Initiative for publicIP related policies, including custom and built-in policies."
    }
  }
}
