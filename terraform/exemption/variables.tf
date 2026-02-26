# ==================== EXEMPTION TERRAFORM ====================
# This configuration handles policy exemptions
# State File: exemption.tfstate
# Triggered by: Changes in policy_exemption.tf, policy_exemptions.auto.tfvars
# Depends on: Policy Deployment Pipeline (must complete first)

variable "policy_exemptions" {
  type = list(object({
    name                            = string
    display_name                    = string 
    scope                           = string
    policy_assignment_id            = string
    policy_definition_reference_ids = optional(list(string))
    exemption_category              = string
    description                     = optional(string)
    expires_on                      = optional(string)
    metadata                        = optional(map(string))
  }))
  default = []
  description = "List of policy exemption configurations"
}

# # Output exemption IDs for validation
# output "exemption_ids" {
#   description = "IDs of created policy exemptions"
#   value = {
#     for k, v in module.policy_exemption :
#     k => try(v.exemption_id, v.id, "")
#   }
#   sensitive = false
# }

# output "exemption_summary" {
#   description = "Summary of deployed exemptions"
#   value = {
#     total_exemptions = length(module.policy_exemption)
#     exemption_names  = [for k, v in module.policy_exemption : v.name]
#   }
#   sensitive = false
# }


# output "exemption_ids" {
#   description = "IDs of created policy exemptions"

#   value = {
#     for k, v in module.policy_exemption :
#     k => v.exemption_ids
#   }
# }

# output "exemption_ids" {
#   description = "IDs of created policy exemptions"
#   value       = module.policy_exemption.exemption_ids
# }

//correct
# output "exemption_ids" {
#   description = "IDs of created policy exemptions"

#   value = {
#     for name, mod in module.policy_exemption :
#     name => mod.exemption_ids
#   }

#   sensitive = false
# }

output "exemption_ids" {
  description = "All policy exemption IDs"

  value = merge([
    for _, mod in module.policy_exemption :
    mod.exemption_ids
  ]...)

  sensitive = false
}


