variable "compartment_id" {
  description = "Compartment OCID where network resources will be created"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for network resource names"
  type        = string
  default     = "finsights-db"
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.100.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private database subnet"
  type        = string
  default     = "10.100.1.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (used by Network Load Balancer)"
  type        = string
  default     = "10.100.0.0/24"
}

variable "allowed_ingress_cidrs" {
  description = "List of external CIDRs allowed to connect to database ports (e.g. VPS nodes or VPN)"
  type        = list(string)
  default     = ["103.249.117.232/32", "103.249.117.201/32"]
}

variable "tags" {
  description = "Tags to attach to network resources"
  type        = map(string)
  default     = {}
}
