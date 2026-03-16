# ------------------ Initiative Loader Modules ------------------
# To add a new initiative/service, add a new module block below and update locals.tf accordingly.

module "update_manager_initiative_loader" {
  source              = "./policySetDefinitions/CHOP-Azure_Update_Manager_initiatives"
  management_group_id = var.management_group_id
}

module "diagnostics_initiative_loader" {
  source              = "./policySetDefinitions/CHOP-Diagnostics-Settings_initiatives"
  management_group_id = var.management_group_id
}

module "recovery_vaults_initiative_loader" {
  source              = "./policySetDefinitions/CHOP-Recovery-Servcies-Vault_initiatives"
  management_group_id = var.management_group_id
}

module "resilience_initiative_loader" {
  source              = "./policySetDefinitions/CHOP-Resilience-(WARA)_initiatives"
  management_group_id = var.management_group_id
}

module "storage_initiative_loader" {
  source              = "./policySetDefinitions/CHOP-Storage-Accounts_initiatives"
  management_group_id = var.management_group_id
}

module "vm_security_agents_initiative_loader" {
  source              = "./policySetDefinitions/CHOP-VM_Security_Agents_initiatives"
  management_group_id = var.management_group_id
}


# ------------------ Initiative Loader Locals ------------------
# Update this locals block when you add a new initiative/service in initiative_loader.tf.

locals {

  initiatives = {

    update_manager = module.update_manager_initiative_loader.azure_update_manager_initiative

    diagnostics    = module.diagnostics_initiative_loader.Diagnostics_initiative

    recovery_vaults = module.recovery_vaults_initiative_loader.RecoveryVaults_initiative

    resilience_wara = module.resilience_initiative_loader.Resilience_initiative

    storage_accounts = module.storage_initiative_loader.storage_accounts_initiative

    vm_security_agents = module.vm_security_agents_initiative_loader.vm_monitoring_security_initiative
  }

}