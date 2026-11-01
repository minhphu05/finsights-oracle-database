output "bucket_id" {
  description = "OCID of the Object Storage bucket"
  value       = oci_objectstorage_bucket.this.bucket_id
}

output "bucket_name" {
  description = "Name of the bucket"
  value       = oci_objectstorage_bucket.this.name
}

output "namespace" {
  description = "Object Storage namespace for this tenancy"
  value       = data.oci_objectstorage_namespace.this.namespace
}

output "s3_compatible_endpoint" {
  description = "S3-compatible API endpoint format"
  value       = "https://${data.oci_objectstorage_namespace.this.namespace}.compat.objectstorage.<region>.oraclecloud.com"
}
