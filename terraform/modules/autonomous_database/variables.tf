variable "compartment_id" {
  description = "Compartment OCID where the Autonomous Database will be created"
  type        = string
}

variable "db_name" {
  description = "Database name: alphanumeric characters only, max 14 characters, must start with a letter"
  type        = string
  default     = "finsightsvec"
}

variable "display_name" {
  description = "Display name for the Autonomous Database in OCI console"
  type        = string
  default     = "finsights-adb-23ai-vector"
}

variable "admin_password" {
  description = "Administrator password for the database (12-30 characters, mixed case, numbers, special characters)"
  type        = string
  sensitive   = true
}

variable "db_version" {
  description = "Oracle Database version (23ai recommended for AI Vector Search)"
  type        = string
  default     = "23ai"
}

variable "db_workload" {
  description = "Autonomous Database workload type (OLTP for Transaction Processing + Vector Search, or AJD for Autonomous JSON Database)"
  type        = string
  default     = "OLTP"
}

variable "is_free_tier" {
  description = "Indicates if this is an Always Free Autonomous Database"
  type        = bool
  default     = true
}

variable "compute_model" {
  description = "Compute model: ECPU or OCPU (OCI 23ai Always Free uses ECPU)"
  type        = string
  default     = "ECPU"
}

variable "compute_count" {
  description = "Number of ECPUs or OCPUs allocated (Always Free tier provides 2 ECPUs)"
  type        = number
  default     = 2
}

variable "whitelisted_ips" {
  description = "List of allowed client IPv4 CIDRs to restrict access. If empty, all clients with mTLS wallet are allowed."
  type        = list(string)
  default     = []
}

variable "subnet_id" {
  description = "Optional private subnet OCID for private endpoint. Leave null for secure public mTLS wallet endpoint."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to attach to the Autonomous Database"
  type        = map(string)
  default     = {}
}
