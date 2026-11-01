variable "compartment_id" {
  description = "Compartment OCID where the MySQL Database System will be created"
  type        = string
}

variable "availability_domain" {
  description = "Availability domain name for MySQL DB System (optional, defaults to first AD in region)"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Private Subnet OCID for MySQL Database System placement"
  type        = string
}

variable "display_name" {
  description = "Display name for the MySQL Database System"
  type        = string
  default     = "finsights-mysql-db"
}

variable "shape_name" {
  description = "Compute shape for the MySQL DB System (e.g. MySQL.Free or MySQL.2 / MySQL.4 ECPU shapes)"
  type        = string
  default     = "MySQL.Free"
}

variable "admin_username" {
  description = "Administrator username for MySQL"
  type        = string
  default     = "finsightsadmin"
}

variable "admin_password" {
  description = "Administrator password for MySQL (minimum 8 characters, mixed case, numbers, special characters)"
  type        = string
  sensitive   = true
}

variable "data_storage_size_in_gb" {
  description = "Allocated storage size in GB"
  type        = number
  default     = 50
}

variable "enable_heatwave" {
  description = "Enable MySQL HeatWave in-memory analytics cluster acceleration"
  type        = bool
  default     = false
}

variable "heatwave_cluster_size" {
  description = "Number of HeatWave analytics nodes (minimum 1)"
  type        = number
  default     = 1
}

variable "heatwave_shape_name" {
  description = "Shape for HeatWave cluster nodes (e.g. HeatWave.Free or HeatWave.32GB)"
  type        = string
  default     = "HeatWave.Free"
}

variable "tags" {
  description = "Tags to attach to the MySQL DB System"
  type        = map(string)
  default     = {}
}
