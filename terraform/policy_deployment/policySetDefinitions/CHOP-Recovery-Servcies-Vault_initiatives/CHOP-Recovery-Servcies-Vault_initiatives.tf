variable "management_group_id" {
  description = "Optional management group ID for policy definition scope. If not set, policy is created at subscription scope."
  type        = string
  default     = "0b41911c-2a00-428b-993b-9b7298dad57d"
}
locals {
  custom_policy_files = fileset("${path.module}/../../policyDefinitions/CHOP-Recovery-Servcies-Vault", "*.json")
  policy_parameters = jsondecode(file("${path.module}/../../parameters/CHOP-Recovery-Servcies-Vault.json"))
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
      jsondecode(file("${path.module}/../../policyDefinitions/CHOP-Recovery-Servcies-Vault/${file}")).metadata,
      "custom_policy_mapping",null
    )
  }
}

module "custom_policy" {
  source              = "../../modules/policy_definition"
  for_each            = toset(local.custom_policy_files)
  policy_json_path    = "${path.module}/../../policyDefinitions/CHOP-Recovery-Servcies-Vault/${each.key}"
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
        name = "[Preview]: Configure Azure Recovery Services vaults to disable public network access"
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/04726aae-4e8d-427c-af7d-ecf56d490022"
        parameter_values = jsonencode(lookup(local.policy_parameters, "[Preview]: Configure Azure Recovery Services vaults to disable public network access", {}))
        policy_group_names          = []
      },
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

output "RecoveryVaults_initiative" {
  value = {
    name         = "CHOP-Recovery Servcies Vault-initiative"
    display_name = "CHOP-Recovery Servcies Vault Initiative"
    description  = "Initiative for CHOP-Diagnostics Settings resources, including custom and built-in policies."
    policy_definitions = local.policy_definitions
    policy_definition_groups = local.filtered_policy_definition_groups
    metadata = {
      category    = "CHOP-Recovery Servcies Vault"
      created_by  = "Terraform"
      description = "Initiative for CHOP-Recovery Servcies Vault resources, including custom and built-in policies."
    }
  }
}