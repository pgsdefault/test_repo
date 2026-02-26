# ------------------ Policy Exemption Modules ------------------
module "policy_exemption" {
  source = "./modules/policy_exemption"
  for_each = { for ex in var.policy_exemptions : ex.name => ex }
  name = each.value.name
  display_name = each.value.display_name
  scope = each.value.scope
  policy_assignment_id = each.value.policy_assignment_id
  policy_definition_reference_ids = lookup(each.value, "policy_definition_reference_ids", [])
  exemption_category = each.value.exemption_category
  description = lookup(each.value, "description", null)
  expires_on = lookup(each.value, "expires_on", null)
  metadata = lookup(each.value, "metadata", null)
}
