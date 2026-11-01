variable "compartment_id" {
  description = "Compartment OCID where the Object Storage bucket will be created"
  type        = string
}

variable "bucket_name" {
  description = "Name of the Object Storage bucket"
  type        = string
  default     = "finsights-data-assets"
}

variable "access_type" {
  description = "Bucket access type: NoPublicAccess or ObjectRead"
  type        = string
  default     = "NoPublicAccess"
}

variable "storage_tier" {
  description = "Storage tier: Standard (Always Free includes 10 GB standard) or Archive"
  type        = string
  default     = "Standard"
}

variable "versioning" {
  description = "Object versioning status: Enabled, Suspended, or Disabled"
  type        = string
  default     = "Disabled"
}

variable "tags" {
  description = "Tags to attach to the bucket"
  type        = map(string)
  default     = {}
}
