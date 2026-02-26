# ==================== POLICY DEPLOYMENT MAIN CONFIGURATION ====================
# This file references the common modules and policy-specific resources
# Symlinks to: ../../initiative_loader.tf, ../../initiative_modules.tf, ../../locals.tf

# Import initiative definitions from parent directory
# These are referenced via symlink or path during terraform init
# terraform init -backend-config="key=policy_deployment.tfstate"

# Module references (these files should be symlinked or copied from parent)
# - initiative_loader.tf (contains: local.initiatives)
# - initiative_modules.tf (contains: module.initiative, module.initiative_assignment)
# - locals.tf (contains: local.initiative_ids)

# The actual content from initiative_loader.tf should be included here
# For now, we reference the modules via ../../ path
# This will be executed in the policy_deployment directory context
