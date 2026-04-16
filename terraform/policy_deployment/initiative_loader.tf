# ------------------ Initiative Loader Modules ------------------
# To add a new initiative/service, add a new module block below and update locals.tf accordingly.

module "update_manager_initiative_loader" {
  source              = "./policySetDefinitions/CHOP-Azure_Update_Manager_initiatives"
  management_group_id = var.management_group_id
}

module "diagnostics_eus2_initiative_loader" {
  source              = "./policySetDefinitions/CHOP-Diagnostics-Settings-eus2_initiatives"
  management_group_id = var.management_group_id
}

module "diagnostics_cus_initiative_loader" {
  source              = "./policySetDefinitions/CHOP-Diagnostics-Settings-cus_initiatives"
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

module "inherit_mandatory_tags_initiative_loader" {
  source              = "./policySetDefinitions/CHOP-Inherit-Mandatory-Tags_initiatives"
  management_group_id = var.management_group_id
}


# ------------------ Initiative Loader Locals ------------------
# Update this locals block when you add a new initiative/service in initiative_loader.tf.

locals {

  initiatives = {

    Update_Manager = module.update_manager_initiative_loader.azure_update_manager_initiative

    Diagnostics_EUS2 = module.diagnostics_eus2_initiative_loader.Diagnostics_eus2_initiative

    Diagnostics_CUS = module.diagnostics_cus_initiative_loader.Diagnostics_cus_initiative

    Recovery_Vaults = module.recovery_vaults_initiative_loader.RecoveryVaults_initiative

    Resilience_WARA = module.resilience_initiative_loader.Resilience_initiative

    Storage_Accounts = module.storage_initiative_loader.storage_accounts_initiative

    VM_Security_Agents = module.vm_security_agents_initiative_loader.vm_monitoring_security_initiative

    Inherit_Tags = module.inherit_mandatory_tags_initiative_loader.Inherit_Tags_initiative
  }

}