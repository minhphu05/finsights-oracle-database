# ==============================================================================
# Account 1 Authentication (Tokyo)
# ==============================================================================
variable "account1_tenancy_ocid" {
  description = "OCID of Account 1 tenancy (Tokyo)"
  type        = string
}

variable "account1_user_ocid" {
  description = "OCID of Account 1 user"
  type        = string
}

variable "account1_fingerprint" {
  description = "Fingerprint for Account 1 API signing key"
  type        = string
}

variable "account1_private_key_path" {
  description = "Local path to Account 1 private key PEM (e.g. .oci/account1.pem)"
  type        = string
  default     = ""
}

variable "account1_private_key_content" {
  description = "Raw content of Account 1 private key PEM (for GitHub Actions Secret)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "account1_region" {
  description = "OCI region for Account 1"
  type        = string
  default     = "ap-tokyo-1"
}

variable "account1_compartment_id" {
  description = "Compartment OCID for Account 1 resources"
  type        = string
}

variable "account1_availability_domain" {
  description = "Target Availability Domain for Account 1 MySQL placement (optional, defaults to first AD in region)"
  type        = string
  default     = ""
}

variable "account1_vcn_cidr" {
  description = "VCN CIDR block for Account 1 (Tokyo)"
  type        = string
  default     = "10.100.0.0/16"
}

variable "account1_private_subnet_cidr" {
  description = "Private Subnet CIDR block for Account 1 (Tokyo)"
  type        = string
  default     = "10.100.1.0/24"
}

# ==============================================================================
# Account 2 Authentication (Singapore)
# ==============================================================================
variable "enable_account2" {
  description = "Whether to provision resources in Account 2 (Singapore)"
  type        = bool
  default     = true
}

variable "account2_tenancy_ocid" {
  description = "OCID of Account 2 tenancy (Singapore)"
  type        = string
  default     = ""
}

variable "account2_user_ocid" {
  description = "OCID of Account 2 user"
  type        = string
  default     = ""
}

variable "account2_fingerprint" {
  description = "Fingerprint for Account 2 API signing key"
  type        = string
  default     = ""
}

variable "account2_private_key_path" {
  description = "Local path to Account 2 private key PEM (e.g. .oci/account2.pem)"
  type        = string
  default     = ""
}

variable "account2_private_key_content" {
  description = "Raw content of Account 2 private key PEM (for GitHub Actions Secret)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "account2_region" {
  description = "OCI region for Account 2"
  type        = string
  default     = "ap-singapore-1"
}

variable "account2_compartment_id" {
  description = "Compartment OCID for Account 2 resources"
  type        = string
  default     = ""
}

variable "account2_availability_domain" {
  description = "Target Availability Domain for Account 2 MySQL placement (optional, defaults to first AD in region)"
  type        = string
  default     = ""
}

variable "account2_vcn_cidr" {
  description = "VCN CIDR block for Account 2 (Singapore)"
  type        = string
  default     = "10.200.0.0/16"
}

variable "account2_private_subnet_cidr" {
  description = "Private Subnet CIDR block for Account 2 (Singapore)"
  type        = string
  default     = "10.200.1.0/24"
}

# ==============================================================================
# Client Network Access (Finsights VPS Nodes)
# ==============================================================================
variable "allowed_ingress_cidrs" {
  description = "List of client CIDRs allowed to connect to database ports (e.g. Finsights VPS nodes)"
  type        = list(string)
  default     = [
    "103.249.117.232/32", # VPS Node 1 (Control Plane)
    "103.249.117.201/32"  # VPS Node 2 (Worker + DB)
  ]
}

# ==============================================================================
# Autonomous Database (Oracle 23ai Always Free Vector DB Settings)
# ==============================================================================
variable "enable_autonomous_database" {
  description = "Whether to provision Autonomous Database 23ai Always Free"
  type        = bool
  default     = true
}

variable "adb_name" {
  description = "Database name prefix (alphanumeric, max 12 chars; will append 1 and 2 for accounts)"
  type        = string
  default     = "finsightsvec"
}

variable "adb_display_name" {
  description = "Display name base for Autonomous Database"
  type        = string
  default     = "finsights-adb-23ai-vector"
}

variable "adb_admin_password" {
  description = "Administrator password for Autonomous Database (12-30 chars, uppercase, lowercase, number, special char)"
  type        = string
  sensitive   = true
}

variable "adb_version" {
  description = "Oracle Database version (23ai supports native AI Vector Search)"
  type        = string
  default     = "23ai"
}

variable "adb_workload" {
  description = "Autonomous Database workload type (OLTP for Transaction Processing + Vector Search)"
  type        = string
  default     = "OLTP"
}

# ==============================================================================
# Object Storage Settings
# ==============================================================================
variable "enable_object_storage" {
  description = "Whether to provision OCI Object Storage bucket"
  type        = bool
  default     = true
}

variable "bucket_name" {
  description = "Base name for Object Storage buckets"
  type        = string
  default     = "finsights-data-assets"
}

variable "bucket_access_type" {
  description = "Access type for the bucket: NoPublicAccess or ObjectRead"
  type        = string
  default     = "NoPublicAccess"
}

# ==============================================================================
# MySQL Database System & HeatWave Settings
# ==============================================================================
variable "enable_mysql" {
  description = "Whether to provision OCI MySQL Database System"
  type        = bool
  default     = true
}

variable "mysql_display_name" {
  description = "Display name base for MySQL Database System"
  type        = string
  default     = "finsights-mysql-db"
}

variable "mysql_shape_name" {
  description = "Compute shape for MySQL DB System (e.g. MySQL.VM.Standard.E3.1.8GB or MySQL.Free if supported)"
  type        = string
  default     = "MySQL.VM.Standard.E3.1.8GB"
}

variable "mysql_admin_username" {
  description = "Administrator username for MySQL"
  type        = string
  default     = "finsightsadmin"
}

variable "mysql_admin_password" {
  description = "Administrator password for MySQL (minimum 8 characters)"
  type        = string
  sensitive   = true
}

variable "mysql_data_storage_size_in_gb" {
  description = "Storage size in GB for MySQL Database System"
  type        = number
  default     = 50
}

variable "enable_heatwave" {
  description = "Enable MySQL HeatWave analytics cluster acceleration"
  type        = bool
  default     = false
}

variable "heatwave_cluster_size" {
  description = "Number of HeatWave cluster analytics nodes (minimum 1)"
  type        = number
  default     = 1
}

variable "heatwave_shape_name" {
  description = "Compute shape for HeatWave cluster nodes (e.g. HeatWave.Free or HeatWave.VM.Standard.E3)"
  type        = string
  default     = "HeatWave.VM.Standard.E3"
}

# ==============================================================================
# Common Tags
# ==============================================================================
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
