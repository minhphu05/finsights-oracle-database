terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

# Fetch availability domains if not explicitly provided
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# 1. MySQL Database System
resource "oci_mysql_mysql_db_system" "this" {
  compartment_id          = var.compartment_id
  availability_domain     = var.availability_domain != "" ? var.availability_domain : data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name            = var.display_name
  shape_name              = var.shape_name
  subnet_id               = var.subnet_id
  admin_username          = var.admin_username
  admin_password          = var.admin_password
  data_storage_size_in_gb = var.data_storage_size_in_gb
  is_highly_available     = false
  port                    = 3306
  port_x                  = 33060

  backup_policy {
    is_enabled        = true
    retention_in_days = 7
  }

  freeform_tags = var.tags

  lifecycle {
    ignore_changes = [
      admin_password
    ]
  }
}

# 2. Optional MySQL HeatWave Analytics Cluster
resource "oci_mysql_heat_wave_cluster" "this" {
  count                = var.enable_heatwave ? 1 : 0
  db_system_id         = oci_mysql_mysql_db_system.this.id
  cluster_size         = var.heatwave_cluster_size
  shape_name           = var.heatwave_shape_name
  is_lakehouse_enabled = false

  lifecycle {
    ignore_changes = [
      cluster_size
    ]
  }
}
