# ==================== REMEDIATION TERRAFORM ====================
# This configuration handles policy remediation tasks
# State File: remediation.tfstate
# Triggered by: Changes in policy_remediation.tf, policy_remediations.auto.tfvars
# Depends on: Policy Deployment Pipeline (must complete first)

# variable "management_group_remediations" {
#   description = "List of remediation objects to create at management group scope."
#   type = list(object({
#     name                      = string
#     scope                     = string
#     policy_assignment_id      = string
#     policy_definition_reference_id = optional(string)
#     resource_discovery_mode   = optional(string, "ExistingNonCompliant")
#     parallel_deployment_count = optional(number)
#     filters                   = optional(map(string))
#   }))
#   default = []
# }

# variable "subscription_remediations" {
#   description = "List of remediation objects to create at subscription scope."
#   type = list(object({
#     name                      = string
#     scope                     = string
#     policy_assignment_id      = string
#     policy_definition_reference_id = optional(string)
#     resource_discovery_mode   = optional(string, "ExistingNonCompliant")
#     parallel_deployment_count = optional(number)
#     filters                   = optional(map(string))
#   }))
#   default = []
# }

# variable "resource_group_remediations" {
#   description = "List of remediation objects to create at resource group scope."
#   type = list(object({
#     name                      = string
#     scope                     = string
#     policy_assignment_id      = string
#     policy_definition_reference_id = optional(string)
#     resource_discovery_mode   = optional(string, "ExistingNonCompliant")
#     parallel_deployment_count = optional(number)
#     filters                   = optional(map(string))
#   }))
#   default = []
# }

# variable "resource_remediations" {
#   description = "List of remediation objects to create at resource scope."
#   type = list(object({
#     name                      = string
#     scope                     = string
#     policy_assignment_id      = string
#     policy_definition_reference_id = optional(string)
#     resource_discovery_mode   = optional(string, "ExistingNonCompliant")
#     parallel_deployment_count = optional(number)
#     filters                   = optional(map(string))
#   }))
#   default = []
# }
variable "management_group_remediations" {
  description = "Remediation objects for management group scope."
  type = list(object({
    name                 = string
    management_group_id  = string
    policy_assignment_id = string
    policy_definition_reference_id = optional(string)
    location_filters     = optional(list(string))
    failure_percentage   = optional(number)
    parallel_deployments = optional(number)
    resource_count       = optional(number)
  }))
  default = []
}

variable "subscription_remediations" {
  description = "Remediation objects for subscription scope."
  type = list(object({
    name                 = string
    subscription_id      = string
    policy_assignment_id = string
    policy_definition_reference_id = optional(string)
    location_filters     = optional(list(string))
    failure_percentage   = optional(number)
    parallel_deployments = optional(number)
    resource_count       = optional(number)
  }))
  default = []
}

variable "resource_group_remediations" {
  description = "Remediation objects for resource group scope."
  type = list(object({
    name                 = string
    resource_group_id    = string
    policy_assignment_id = string
    policy_definition_reference_id = optional(string)
    location_filters     = optional(list(string))
    failure_percentage   = optional(number)
    parallel_deployments = optional(number)
    resource_count       = optional(number)
  }))
  default = []
}

variable "resource_remediations" {
  description = "Remediation objects for resource scope."
  type = list(object({
    name                 = string
    resource_id          = string
    policy_assignment_id = string
    policy_definition_reference_id = optional(string)
    location_filters     = optional(list(string))
    failure_percentage   = optional(number)
    parallel_deployments = optional(number)
    resource_count       = optional(number)
  }))
  default = []
}
# Output remediation task IDs for validation
output "remediation_task_ids" {
  description = "IDs of created remediation tasks"
  value = {
    # management_group = try([for t in module.policy_remediation.management_group_remediation_tasks : t.id], [])
    # subscriptions    = try([for t in module.policy_remediation.subscription_remediation_tasks : t.id], [])
    # # resource_groups  = try([for t in module.policy_remediation.resource_group_remediation_tasks : t.id], [])
    # resources        = try([for t in module.policy_remediation.resource_remediation_tasks : t.id], [])
    management_group = module.policy_remediation.management_group_remediation_ids
    subscriptions    = module.policy_remediation.subscription_remediation_ids
    resource_groups = module.policy_remediation.resource_group_remediation_ids
    resources        = module.policy_remediation.resource_remediation_ids
  }
  sensitive = false
}
