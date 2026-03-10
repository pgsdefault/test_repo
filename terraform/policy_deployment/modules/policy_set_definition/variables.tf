# ---------------------------
# Variables for Policy Set Definition Module
# ---------------------------
variable "name" {}
variable "display_name" {}
variable "policy_type" { default = "Custom" }
variable "policy_definitions" { type = list(object({
	policy_definition_id = string
	parameter_values    = optional(string, "{}")
  policy_group_names   = optional(list(string), [])
})) }
variable "metadata" { default = "{\"category\":\"General\"}" }
variable "description" {
	type        = string
	default     = ""
	description = "Description of the policy set (initiative)."
}
 
variable "delete_initiatives" {
  description = "Map of initiative names to boolean for deletion. Default is false (do not delete)."
  type        = map(bool)
  default     = {}
}

variable "scope_exclusions" {
  description = "Map of scope to list of policy or initiative names to exclude from that scope."
  type        = map(list(string))
  default     = {}
}

variable "management_group_id" {
  description = "Optional management group ID for initiative definition scope. If not set, initiative is created at subscription scope."
  type        = string
  default     = "0b41911c-2a00-428b-993b-9b7298dad57d"
}

variable "policy_definition_groups" {
  description = "Policy groups inside initiatives"
  type = list(object({
    name         = string
    display_name = string
    description  = optional(string)
    category     = optional(string)
  }))
  default = []
}
