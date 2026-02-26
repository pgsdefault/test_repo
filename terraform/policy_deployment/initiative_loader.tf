# ------------------ Initiative Loader Modules ------------------
# To add a new initiative/service, add a new module block below and update locals.tf accordingly.
# Example:
# module "storage_initiative_loader" {
#   source = "./policySetDefinitions/storage_initiatives"
# }


module "ZeroTrust_initiative_loader" {
  source              = "./policySetDefinitions/ZeroTrust_initiatives"
  management_group_id = var.management_group_id
}

module "PublicNetworkAccess_initiative_loader" {
  source              = "./policySetDefinitions/PublicNetworkAccess_initiatives"
  management_group_id = var.management_group_id
}

module "EncryptionAtRest_initiative_loader" {
  source              = "./policySetDefinitions/EncryptionAtRest_initiatives"
  management_group_id = var.management_group_id
}

module "publicIP_initiative_loader" {
  source              = "./policySetDefinitions/publicIP_initiatives"
  management_group_id = var.management_group_id
}


# ------------------ Initative Loader Locals ------------------
# Update this locals block when you add a new initiative/service in initiative_loader.tf.
locals {
  initiatives = {
    ZeroTrust           = module.ZeroTrust_initiative_loader.ZeroTrust_initiative
    PublicNetworkAccess = module.PublicNetworkAccess_initiative_loader.PublicNetworkAccess_initiative
    EncryptionAtRest    = module.EncryptionAtRest_initiative_loader.EncryptionAtRest_initiative
    publicIP            = module.publicIP_initiative_loader.publicIP_initiative

    # Add new initiatives here, e.g.:
    # storage = module.storage_initiative_loader.storage_initiative
  }
}
