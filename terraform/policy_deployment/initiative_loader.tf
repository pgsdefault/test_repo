# ------------------ Initiative Loader Modules ------------------
# To add a new initiative/service, add a new module block below and update locals.tf accordingly.
# Example:
# module "storage_initiative_loader" {
#   source = "./policySetDefinitions/storage_initiatives"
# }


module "UpdateManager_initiative_loader" {
  source              = "./policySetDefinitions/CHOP-Azure_Update_Manager_initiatives"
  management_group_id = var.management_group_id
}

module "Diagnostics_initiative_loader" {
  source              = "./policySetDefinitions/CHOP-Diagnostics-Settings_initiatives"
  management_group_id = var.management_group_id
}

module "RecoveryVaults_initiative_loader" {
  source              = "./policySetDefinitions/CHOP-Recovery-Servcies-Vault_initiatives"
  management_group_id = var.management_group_id
}

module "Resilience_initiative_loader" {
  source              = "./policySetDefinitions/CHOP-Resilience-(WARA)_initiatives"
  management_group_id = var.management_group_id
}


# ------------------ Initative Loader Locals ------------------
# Update this locals block when you add a new initiative/service in initiative_loader.tf.
locals {
  initiatives = {
    UM           = module.UpdateManager_initiative_loader.azure_update_manager_initiative
    Diagnostic = module.Diagnostics_initiative_loader.Diagnostics_initiative
    RecoveryVa    = module.RecoveryVaults_initiative_loader.RecoveryVaults_initiative
    Resilience            = module.Resilience_initiative_loader.Resilience_initiative

    # Add new initiatives here, e.g.:
    # storage = module.storage_initiative_loader.storage_initiative
  }
}
