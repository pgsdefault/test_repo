# ==================== POLICY DEPLOYMENT TERRAFORM ====================
# This configuration handles policy definitions and assignments
# State File: policy_deployment.tfstate
# Triggered by: Changes in initiative_loader.tf, initiative_modules.tf, policyDefinitions/

variable "management_group_id" {
  description = "Optional management group ID for policy definition scope. If not set, policy is created at subscription scope."
  type        = string
  default     = "0b41911c-2a00-428b-993b-9b7298dad57d"
}

variable "policy_exclusions" {
  description = "Map of assignment names to list of resource IDs to exclude from policy assignment (not_scopes)."
  type        = map(list(string))
  default     = {}
}

variable "delete_initiatives" {
  description = "Map of initiative names to boolean for deletion. Default is false (do not delete)."
  type        = map(bool)
  default     = {}
}

variable "skip_policies" {
  description = "List of policy definition names to skip in initiatives."
  type        = list(string)
  default     = []
}

variable "scope_exclusions" {
  description = "Map of scope to list of policy or initiative names to exclude from that scope."
  type        = map(list(string))
  default     = {}
}

# Output the initiative IDs for dependent pipelines (remediation, exemption)
# output "initiative_ids" {
#   description = "Initiative IDs created by this pipeline for reference by other pipelines"
#   value = {
#     for k, v in module.initiative :
#     k => {
#       policy_set_definition_id = v.policy_set_definition_id
#       description              = try(v.description, "")
#     }
#   }
#   sensitive = false
# }

# output "policy_assignment_ids" {
#   description = "Policy assignment IDs for reference by remediation and exemption pipelines"
#   value = {
#     for k, v in module.initiative_assignment.assignments :
#     k => try(v.id, v.resource_id, "")
#   }
#   sensitive = false
# }

//trying
# output "policy_assignment_ids" {
#   description = "Policy assignment IDs for reference by remediation and exemption pipelines"
#   value = {
#     for k, v in module.initiative_assignment :
#     k => try(v.id, v.resource_id, "")
#   }
#   sensitive = false
# }




output "initiative_ids" {
  description = "Map of initiative names to their policy set definition IDs and descriptions."
  value = local.initiative_ids
}
output "policy_assignment_ids" {
  description = "Policy assignment IDs for remediation and exemption pipelines"
  value       = module.initiative_assignment.policy_assignment_ids
}

