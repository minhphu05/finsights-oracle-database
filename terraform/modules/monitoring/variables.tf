variable "compartment_id" {
  description = "Compartment OCID where monitoring resources will be created"
  type        = string
}

variable "name_prefix" {
  description = "Name prefix for alarms, topics, and install keys"
  type        = string
  default     = "finsights"
}

variable "adb_id" {
  description = "OCID of Autonomous Database to monitor"
  type        = string
  default     = ""
}

variable "mysql_id" {
  description = "OCID of MySQL DB System to monitor"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to attach to monitoring resources"
  type        = map(string)
  default     = {}
}
