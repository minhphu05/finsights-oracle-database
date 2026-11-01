terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

resource "oci_database_autonomous_database" "this" {
  compartment_id                      = var.compartment_id
  db_name                             = var.db_name
  display_name                        = var.display_name
  admin_password                      = var.admin_password
  db_version                          = var.db_version
  db_workload                         = var.db_workload
  is_free_tier                        = var.is_free_tier
  compute_model                       = var.compute_model
  compute_count                       = var.compute_count
  data_storage_size_in_tbs            = var.is_free_tier ? null : 1
  is_auto_scaling_enabled             = false
  is_auto_scaling_for_storage_enabled = false
  license_model                       = "LICENSE_INCLUDED"
  subnet_id                           = var.subnet_id
  is_mtls_connection_required         = true
  freeform_tags                       = var.tags

  lifecycle {
    ignore_changes = [
      data_storage_size_in_tbs,
      compute_count
    ]
  }
}

# Download regional/instance wallet for secure client connections
resource "oci_database_autonomous_database_wallet" "this" {
  autonomous_database_id = oci_database_autonomous_database.this.id
  password               = var.admin_password
  base64_encode_content  = true
  generate_type          = "ALL"
}
