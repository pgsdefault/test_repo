variable "assignments" {
  description = "Map of assignment objects for policy assignments."
  type = map(object({
    name                      = string
    scope                     = string
    policy_definition_id      = string
    parameters                = any
    description               = string
    assigned_by               = string
    location                  = string
    user_assigned_identity_id = string
    exclusions                = list(string)
  }))
  default = {}
}
