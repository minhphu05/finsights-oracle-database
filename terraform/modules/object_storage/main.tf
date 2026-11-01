terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

# Fetch tenancy object storage namespace
data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_id
}

# Create Object Storage bucket
resource "oci_objectstorage_bucket" "this" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.this.namespace
  name           = var.bucket_name
  access_type    = var.access_type
  storage_tier   = var.storage_tier
  versioning     = var.versioning
  freeform_tags  = var.tags
}
