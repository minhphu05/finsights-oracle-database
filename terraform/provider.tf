# ==============================================================================
# Oracle Cloud Providers for Multi-Tenancy Architecture
# ==============================================================================

# Default Provider (Points to Account 1)
provider "oci" {
  tenancy_ocid     = var.account1_tenancy_ocid
  user_ocid        = var.account1_user_ocid
  fingerprint      = var.account1_fingerprint
  private_key_path = var.account1_private_key_path != "" ? var.account1_private_key_path : null
  private_key      = var.account1_private_key_content != "" ? var.account1_private_key_content : null
  region           = var.account1_region
}

# Explicit Provider for Account 1 (Tokyo - Primary)
provider "oci" {
  alias            = "account1"
  tenancy_ocid     = var.account1_tenancy_ocid
  user_ocid        = var.account1_user_ocid
  fingerprint      = var.account1_fingerprint
  private_key_path = var.account1_private_key_path != "" ? var.account1_private_key_path : null
  private_key      = var.account1_private_key_content != "" ? var.account1_private_key_content : null
  region           = var.account1_region
}

# Explicit Provider for Account 2 (Singapore - Secondary)
provider "oci" {
  alias            = "account2"
  tenancy_ocid     = var.account2_tenancy_ocid != "" ? var.account2_tenancy_ocid : var.account1_tenancy_ocid
  user_ocid        = var.account2_user_ocid != "" ? var.account2_user_ocid : var.account1_user_ocid
  fingerprint      = var.account2_fingerprint != "" ? var.account2_fingerprint : var.account1_fingerprint
  private_key_path = var.account2_private_key_path != "" ? var.account2_private_key_path : null
  private_key      = var.account2_private_key_content != "" ? var.account2_private_key_content : (var.account1_private_key_content != "" ? var.account1_private_key_content : null)
  region           = var.account2_region
}
