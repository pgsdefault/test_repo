# ------------------ Variables for Policy Remediation Module ------------------
# Pass remediation objects for each scope as needed.

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
