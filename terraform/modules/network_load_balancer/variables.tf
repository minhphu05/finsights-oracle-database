variable "compartment_id" {
  description = "Compartment OCID where the Network Load Balancer will be created"
  type        = string
}

variable "display_name" {
  description = "Display name for the Network Load Balancer"
  type        = string
  default     = "finsights-mysql-nlb"
}

variable "subnet_id" {
  description = "Public Subnet OCID for the Network Load Balancer placement"
  type        = string
}

variable "target_private_ip" {
  description = "Private IP of the MySQL DB System backend"
  type        = string
}

variable "tags" {
  description = "Tags to attach to the Network Load Balancer"
  type        = map(string)
  default     = {}
}
