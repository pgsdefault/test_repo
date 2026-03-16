variable "management_group_id" {
  description = "Management group ID for policy definition scope"
  type        = string
  default     = "mymg"
}

locals {
  custom_policy_files = fileset("${path.module}/../../policyDefinitions/CHOP-VM-SecurityAgents", "*.json")
  policy_parameters   = jsondecode(file("${path.module}/../../parameters/CHOP-VM-SecurityAgents.json"))
  policy_group_files  = fileset("${path.module}/../../compliance_standard", "*.json")

  policy_definition_groups = flatten([
    for f in local.policy_group_files :
    jsondecode(file("${path.module}/../../compliance_standard/${f}"))
  ])

  custom_policy_group_mapping = {
    for file in local.custom_policy_files :
    file => lookup(
      jsondecode(file("${path.module}/../../policyDefinitions/CHOP-VM-SecurityAgents/${file}")).metadata,
      "custom_policy_mapping",
      null
    )
  }
}

module "custom_policy" {
  source              = "../../modules/policy_definition"
  for_each            = toset(local.custom_policy_files)
  policy_json_path    = "${path.module}/../../policyDefinitions/CHOP-VM-SecurityAgents/${each.key}"
  management_group_id = var.management_group_id
  name = lower(replace(replace(each.key, ".json", ""), " ", "-"))
}

locals {

  policy_definitions = [

    {
      name                 = "mde-windows-agent"
      policy_definition_id = "/providers/microsoft.authorization/policydefinitions/1ec9c2c2-6d64-656d-6465-3ec3309b8579"
      parameter_values     = jsonencode(lookup(local.policy_parameters, "[Preview]: Deploy Microsoft Defender for Endpoint agent on Windows virtual machines", {}))
      policy_group_names   = []
    },

    {
      name                 = "mde-linux-agent"
      policy_definition_id = "/providers/microsoft.authorization/policydefinitions/d30025d0-6d64-656d-6465-67688881b632"
      parameter_values     = jsonencode(lookup(local.policy_parameters, "[Preview]: Deploy Microsoft Defender for Endpoint agent on Linux virtual machines", {}))
      policy_group_names   = []
    },

    {
      name                 = "ama-windows-ua-mi"
      policy_definition_id = "/providers/microsoft.authorization/policydefinitions/637125fd-7c39-4b94-bb0a-d331faf333a9"
      parameter_values     = jsonencode(lookup(local.policy_parameters, "Configure Windows virtual machines to run Azure Monitor Agent with user-assigned managed identity-based authentication", {}))
      policy_group_names   = []
    },

    {
      name                 = "ama-linux-ua-mi"
      policy_definition_id = "/providers/microsoft.authorization/policydefinitions/ae8a10e6-19d6-44a3-a02d-a2bdfc707742"
      parameter_values     = jsonencode(lookup(local.policy_parameters, "Configure Linux virtual machines to run Azure Monitor Agent with user-assigned managed identity-based authentication", {}))
      policy_group_names   = []
    },

    {
      name                 = "dcr-association-windows"
      policy_definition_id = "/providers/microsoft.authorization/policydefinitions/eab1f514-22e3-42e3-9a1f-e1dc9199355c"
      parameter_values     = jsonencode(lookup(local.policy_parameters, "Configure Windows Machines to be associated with a Data Collection Rule or a Data Collection Endpoint", {}))
      policy_group_names   = []
    },

    {
      name                 = "dcr-association-linux"
      policy_definition_id = "/providers/microsoft.authorization/policydefinitions/2ea82cdd-f2e8-4500-af75-67a2e084ca74"
      parameter_values     = jsonencode(lookup(local.policy_parameters, "Configure Windows Machines to be associated with a Data Collection Rule or a Data Collection Endpoint", {}))
      policy_group_names   = []
    },

    {
      name                 = "update-manager-prerequisite-windows"
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/9905ca54-1471-49c6-8291-7582c04cd4d4"
      parameter_values     = jsonencode(lookup(local.policy_parameters, "Set prerequisite for Scheduling recurring updates on Azure virtual machines-Windows", {}))
      policy_group_names   = []
    },

    {
      name                 = "update-manager-prerequisite-linux"
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/9905ca54-1471-49c6-8291-7582c04cd4d4"
      parameter_values     = jsonencode(lookup(local.policy_parameters, "Set prerequisite for Scheduling recurring updates on Azure virtual machines-Linux", {}))
      policy_group_names   = []
    },

    {
      name                 = "missing-updates-check-windows"
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/59efceea-0c96-497e-a4a1-4eb2290dac15"
      parameter_values     = jsonencode(lookup(local.policy_parameters, "Configure periodic checking for missing system updates on azure virtual machines-Windows", {}))
      policy_group_names = []
    },

    {
      name                 = "missing-updates-check-linux"
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/59efceea-0c96-497e-a4a1-4eb2290dac15"
      parameter_values     = jsonencode(lookup(local.policy_parameters, "Configure periodic checking for missing system updates on azure virtual machines-Linux", {}))
      policy_group_names = []
    },

    {
      name                 = "schedule-recurring-updates-windows"
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ba0df93e-e4ac-479a-aac2-134bbae39a1a"
      parameter_values     = jsonencode(lookup(local.policy_parameters, "Schedule recurring updates using Azure Update Manager-Windows", {}))
      policy_group_names   = []
    },

    {
      name                 = "schedule-recurring-updates-linux"
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ba0df93e-e4ac-479a-aac2-134bbae39a1a"
      parameter_values     = jsonencode(lookup(local.policy_parameters, "Schedule recurring updates using Azure Update Manager-Linux", {}))
      policy_group_names   = []
    }

  ]
}

output "vm_monitoring_security_initiative" {
  value = {
    name         = "CHOP-VM-Monitoring-Security-initiative"
    display_name = "CHOP-EPIC-VM Monitoring and Security Agents Initiative"

    description  = "Deploy Defender agent, Azure Monitor Agent, DCR association and Azure Update Manager policies"

    policy_definitions = local.policy_definitions

    policy_definition_groups = []

    metadata = {
      category    = "Security"
      created_by  = "Terraform"
      description = "VM monitoring and patching compliance initiative"
    }
  }
}