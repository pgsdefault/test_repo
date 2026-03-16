variable "management_group_id" {
  description = "Optional management group ID for policy definition scope. If not set, policy is created at subscription scope."
  type        = string
  default     = "mymg"
}

locals {
  custom_policy_files = fileset("${path.module}/../../policyDefinitions/CHOP-Resilience-(WARA)", "*.json")
  policy_parameters   = jsondecode(file("${path.module}/../../parameters/CHOP-Resilience-(WARA).json"))
  policy_group_files  = fileset("${path.module}/../../compliance_standard", "*.json")

  policy_definition_groups = flatten([
    for f in local.policy_group_files :
    jsondecode(file("${path.module}/../../compliance_standard/${f}"))
  ])

  custom_policy_group_mapping = {
    for file in local.custom_policy_files :
    file => lookup(
      jsondecode(file("${path.module}/../../policyDefinitions/CHOP-Resilience-(WARA)/${file}")).metadata,
      "custom_policy_mapping",
      null
    )
  }
}

module "custom_policy" {
  source              = "../../modules/policy_definition"
  for_each            = toset(local.custom_policy_files)
  policy_json_path    = "${path.module}/../../policyDefinitions/CHOP-Resilience-(WARA)/${each.key}"
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
      { name = "vm-zone-aligned"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/42f4f3a2-7d20-4c13-a05d-01857a626c22"
        parameter_values     = jsonencode(lookup(local.policy_parameters, "[Preview]: Virtual Machines should be Zone Aligned", {}))
        policy_group_names   = []
      },
      { name = "storage-zone-redundant"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/85b005b2-95fc-4953-b9cb-f9ee6427c754"
        parameter_values     = jsonencode(lookup(local.policy_parameters, "[Preview]: Storage Accounts should be Zone Redundant", {}))
        policy_group_names   = []
      },
      { name = "backup-sr-zone-redundant"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ae243d87-5cf3-4dce-90bd-6d62be328de3"
        parameter_values     = jsonencode(lookup(local.policy_parameters, "[Preview]: Backup and Site Recovery should be Zone Redundant", {}))
        policy_group_names   = []
      },
      { name = "lb-zone-resilient"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/42daa901-5969-47ef-92cb-b75df946195a"
        parameter_values     = jsonencode(lookup(local.policy_parameters, "[Preview]: Load Balancers should be Zone Resilient", {}))
        policy_group_names   = []
      },
      { name = "pip-zone-resilient"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/682e4ab9-59fe-4871-9839-265b54c568c4"
        parameter_values     = jsonencode(lookup(local.policy_parameters, "[Preview]: Public IP addresses should be Zone Resilient", {}))
        policy_group_names   = []
      },
      { name = "vng-zone-redundant"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/da8a2248-6b4a-44a7-96bf-bf1c0dd208c3"
        parameter_values     = jsonencode(lookup(local.policy_parameters, "[Preview]: Virtual network gateways should be Zone Redundant", {}))
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

output "Resilience_initiative" {
  value = {
    name                     = "CHOP-Resilience-WARA-initiative"
    display_name             = "CHOP-EPIC-Resilience-(WARA) Initiative"
    description              = "Initiative for CHOP-Resilience (WARA) resources, including custom and built-in policies."
    policy_definitions       = local.policy_definitions
    policy_definition_groups = local.filtered_policy_definition_groups
    metadata = {
      category    = "CHOP-Resilience (WARA)"
      created_by  = "Terraform"
      description = "Initiative for CHOP-Resilience (WARA) resources, including custom and built-in policies."
    }
  }
}