# ---------------------------
# Variables for Policy Definition Module
# ---------------------------
variable "policy_json_path" { description = "Path to the custom policy JSON file" }

variable "management_group_id" {
	description = "Optional management group ID for policy definition scope. If not set, policy is created at subscription scope."
	type        = string
	default     = "0b41911c-2a00-428b-993b-9b7298dad57d"
}

variable "name" {
	description = "Name of the policy definition."
	type        = string
}

variable "delete_policies" {
	description = "Map of policies to delete."
	type        = map(bool)
	default     = {}
}

