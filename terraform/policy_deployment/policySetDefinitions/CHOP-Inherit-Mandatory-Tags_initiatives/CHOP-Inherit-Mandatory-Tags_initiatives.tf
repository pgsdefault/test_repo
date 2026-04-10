variable "management_group_id" {
  description = "Optional management group ID for policy definition scope. If not set, policy is created at subscription scope."
  type        = string
  default     = ""
}

locals {
  custom_policy_files = fileset("${path.module}/../../policyDefinitions/CHOP-Inherit-Mandatory-Tags", "*.json")
  policy_parameters   = jsondecode(file("${path.module}/../../parameters/CHOP-Inherit-Mandatory-Tags.json"))
  policy_group_files  = fileset("${path.module}/../../compliance_standard", "*.json")

  policy_definition_groups = flatten([
    for f in local.policy_group_files :
    jsondecode(file("${path.module}/../../compliance_standard/${f}"))
  ])

  custom_policy_group_mapping = {
    for file in local.custom_policy_files :
    file => lookup(
      jsondecode(file("${path.module}/../../policyDefinitions/CHOP-Inherit-Mandatory-Tags/${file}")).metadata,
      "custom_policy_mapping",
      null
    )
  }
}

module "custom_policy" {
  source              = "../../modules/policy_definition"
  for_each            = toset(local.custom_policy_files)
  policy_json_path    = "${path.module}/../../policyDefinitions/CHOP-Inherit-Mandatory-Tags/${each.key}"
  management_group_id = var.management_group_id
  name = lower(replace(replace(each.key, ".json", ""), " ", "-"))
}

locals {
  policy_definitions = concat(
    [
      for k, mod in module.custom_policy : {
        name                 = lower(replace(replace(k, ".json", ""), " ", "-"))
        policy_definition_id = mod.policy_definition_id
        parameter_values     = jsonencode(lookup(local.policy_parameters, k, {}))
        policy_group_names   = lookup(local.custom_policy_group_mapping, k, [])
      }
    ],
    [
      { name = "inherit-rg-tags-owner"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
        parameter_values     = jsonencode(lookup(local.policy_parameters, "Inherit a tag from the resource group if missing - owner", {}))
        policy_group_names   = []
      },
      { name = "inherit-rg-tags-technical_contact"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
        parameter_values     = jsonencode(lookup(local.policy_parameters, "Inherit a tag from the resource group if missing - technical_contact", {}))
        policy_group_names   = []
      },
      { name = "inherit-rg-tags-support_group"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
        parameter_values     = jsonencode(lookup(local.policy_parameters, "Inherit a tag from the resource group if missing - support_group", {}))
        policy_group_names   = []
      },
      { name = "inherit-rg-tags-application"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
        parameter_values     = jsonencode(lookup(local.policy_parameters, "Inherit a tag from the resource group if missing - application", {}))
        policy_group_names   = []
      },
      { name = "inherit-rg-tags-environment"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
        parameter_values     = jsonencode(lookup(local.policy_parameters, "Inherit a tag from the resource group if missing - environment", {}))
        policy_group_names   = []
      },
      { name = "inherit-rg-tags-automation_version"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
        parameter_values     = jsonencode(lookup(local.policy_parameters, "Inherit a tag from the resource group if missing - automation_version", {}))
        policy_group_names   = []
      },
      { name = "inherit-rg-tags-cost_center"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
        parameter_values     = jsonencode(lookup(local.policy_parameters, "Inherit a tag from the resource group if missing - cost_center", {}))
        policy_group_names   = []
      },
      { name = "inherit-rg-tags-lifecycle"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
        parameter_values     = jsonencode(lookup(local.policy_parameters, "Inherit a tag from the resource group if missing - lifecycle", {}))
        policy_group_names   = []
      }
    ]
  )
}

locals {
  custom_groups_used   = flatten([for g in values(local.custom_policy_group_mapping) : g])
  builtin_groups_used  = flatten([for p in local.policy_definitions : lookup(p, "policy_group_names", [])])
  all_groups_used      = distinct(concat(local.custom_groups_used, local.builtin_groups_used))
  filtered_policy_definition_groups = [
    for g in local.policy_definition_groups : {
      name         = g.name
      display_name = g.display_name
      description  = g.description
      category     = g.category
    } if contains(local.all_groups_used, g.name)
  ]
}

output "Inherit_Tags_initiative" {
  value = {
    name                     = "CHOP-Mandatory-Tags-initiative"
    display_name             = "CHOP-EPIC-Mandatory Tags Initiative"
    description              = "Initiative for CHOP-Mandatory Tags on resources, including custom and built-in policies."
    policy_definitions       = local.policy_definitions
    policy_definition_groups = local.filtered_policy_definition_groups
    metadata = {
      category    = "Tags"
      created_by  = "Terraform"
      description = "Initiative for CHOP-Diagnostics Settings resources, including custom and built-in policies."
    }
  }
}