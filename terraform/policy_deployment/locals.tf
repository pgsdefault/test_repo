# ------------------ Locals ------------------
locals {
  initiative_ids = {
    for s, mod in module.initiative :
    s => {
      policy_set_definition_id = mod.policy_set_definition_id
      description              = local.initiatives[s].description
    }
  }
}
