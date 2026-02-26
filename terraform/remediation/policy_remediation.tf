# ------------------ Policy Remediation Module Block ------------------
# Pass remediation objects for each scope as needed via tfvars.

module "policy_remediation" {
  source = "./modules/policy_remediation"
  management_group_remediations = var.management_group_remediations
  subscription_remediations     = var.subscription_remediations
  resource_group_remediations   = var.resource_group_remediations
  resource_remediations         = var.resource_remediations
}
