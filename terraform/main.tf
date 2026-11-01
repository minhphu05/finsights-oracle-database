locals {
  name_prefix = "finsights"
  common_tags = merge(
    {
      Project     = "Finsights"
      Environment = "production"
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )
}

# ==============================================================================
# Account 1: Tokyo (NRT) - Full Stack (ADB 23ai Vector, Object Storage, MySQL)
# ==============================================================================
module "account1_network" {
  source    = "./modules/network"
  providers = { oci = oci.account1 }

  compartment_id        = var.account1_compartment_id
  name_prefix           = "${local.name_prefix}-tokyo"
  vcn_cidr              = var.account1_vcn_cidr
  private_subnet_cidr   = var.account1_private_subnet_cidr
  allowed_ingress_cidrs = var.allowed_ingress_cidrs
  tags                  = local.common_tags
}

# Autonomous Database 23ai Always Free (AI Vector DB) in Tokyo
module "account1_autonomous_database" {
  count     = var.enable_autonomous_database ? 1 : 0
  source    = "./modules/autonomous_database"
  providers = { oci = oci.account1 }

  compartment_id  = var.account1_compartment_id
  db_name         = "${var.adb_name}1"
  display_name    = "${var.adb_display_name}-tokyo"
  admin_password  = var.adb_admin_password
  db_version      = var.adb_version
  db_workload     = var.adb_workload
  is_free_tier    = true
  compute_model   = "ECPU"
  compute_count   = 2
  whitelisted_ips = var.allowed_ingress_cidrs
  tags            = local.common_tags
}

# Object Storage Bucket (Always Free 10 GB) in Tokyo
module "account1_object_storage" {
  count     = var.enable_object_storage ? 1 : 0
  source    = "./modules/object_storage"
  providers = { oci = oci.account1 }

  compartment_id = var.account1_compartment_id
  bucket_name    = "${var.bucket_name}-tokyo"
  access_type    = var.bucket_access_type
  storage_tier   = "Standard"
  versioning     = "Disabled"
  tags           = local.common_tags
}

# MySQL Database System & HeatWave in Tokyo
module "account1_mysql_heatwave" {
  count     = var.enable_mysql ? 1 : 0
  source    = "./modules/mysql_heatwave"
  providers = { oci = oci.account1 }

  compartment_id          = var.account1_compartment_id
  availability_domain     = var.account1_availability_domain
  subnet_id               = module.account1_network.private_subnet_id
  display_name            = "${var.mysql_display_name}-tokyo"
  shape_name              = var.mysql_shape_name
  admin_username          = var.mysql_admin_username
  admin_password          = var.mysql_admin_password
  data_storage_size_in_gb = var.mysql_data_storage_size_in_gb
  enable_heatwave         = var.enable_heatwave
  heatwave_cluster_size   = var.heatwave_cluster_size
  heatwave_shape_name     = var.heatwave_shape_name
  tags                    = local.common_tags
}

# ==============================================================================
# Account 2: Singapore (SIN) - Full Stack (ADB 23ai Vector, Object Storage, MySQL)
# ==============================================================================
module "account2_network" {
  count     = var.enable_account2 ? 1 : 0
  source    = "./modules/network"
  providers = { oci = oci.account2 }

  compartment_id        = var.account2_compartment_id != "" ? var.account2_compartment_id : var.account1_compartment_id
  name_prefix           = "${local.name_prefix}-singapore"
  vcn_cidr              = var.account2_vcn_cidr
  private_subnet_cidr   = var.account2_private_subnet_cidr
  allowed_ingress_cidrs = var.allowed_ingress_cidrs
  tags                  = local.common_tags
}

# Autonomous Database 23ai Always Free (AI Vector DB) in Singapore
module "account2_autonomous_database" {
  count     = var.enable_account2 && var.enable_autonomous_database ? 1 : 0
  source    = "./modules/autonomous_database"
  providers = { oci = oci.account2 }

  compartment_id  = var.account2_compartment_id != "" ? var.account2_compartment_id : var.account1_compartment_id
  db_name         = "${var.adb_name}2"
  display_name    = "${var.adb_display_name}-singapore"
  admin_password  = var.adb_admin_password
  db_version      = var.adb_version
  db_workload     = var.adb_workload
  is_free_tier    = true
  compute_model   = "ECPU"
  compute_count   = 2
  whitelisted_ips = var.allowed_ingress_cidrs
  tags            = local.common_tags
}

# Object Storage Bucket (Always Free 10 GB) in Singapore
module "account2_object_storage" {
  count     = var.enable_account2 && var.enable_object_storage ? 1 : 0
  source    = "./modules/object_storage"
  providers = { oci = oci.account2 }

  compartment_id = var.account2_compartment_id != "" ? var.account2_compartment_id : var.account1_compartment_id
  bucket_name    = "${var.bucket_name}-singapore"
  access_type    = var.bucket_access_type
  storage_tier   = "Standard"
  versioning     = "Disabled"
  tags           = local.common_tags
}

# MySQL Database System & HeatWave in Singapore
module "account2_mysql_heatwave" {
  count     = var.enable_account2 && var.enable_mysql ? 1 : 0
  source    = "./modules/mysql_heatwave"
  providers = { oci = oci.account2 }

  compartment_id          = var.account2_compartment_id != "" ? var.account2_compartment_id : var.account1_compartment_id
  availability_domain     = var.account2_availability_domain
  subnet_id               = module.account2_network[0].private_subnet_id
  display_name            = "${var.mysql_display_name}-singapore"
  shape_name              = var.mysql_shape_name
  admin_username          = var.mysql_admin_username
  admin_password          = var.mysql_admin_password
  data_storage_size_in_gb = var.mysql_data_storage_size_in_gb
  enable_heatwave         = var.enable_heatwave
  heatwave_cluster_size   = var.heatwave_cluster_size
  heatwave_shape_name     = var.heatwave_shape_name
  tags                    = local.common_tags
}
