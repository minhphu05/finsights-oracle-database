output "id" {
  description = "OCID of the Autonomous Database"
  value       = oci_database_autonomous_database.this.id
}

output "db_name" {
  description = "Database name"
  value       = oci_database_autonomous_database.this.db_name
}

output "db_version" {
  description = "Database version"
  value       = oci_database_autonomous_database.this.db_version
}

output "connection_strings" {
  description = "Database connection profile URLs and TNS names"
  value       = oci_database_autonomous_database.this.connection_strings
}

output "service_console_url" {
  description = "URL to the Oracle Database Actions / SQL Developer Web service console"
  value       = oci_database_autonomous_database.this.service_console_url
}

output "wallet_base64" {
  description = "Base64-encoded client credential wallet zip (sensitive)"
  value       = oci_database_autonomous_database_wallet.this.content
  sensitive   = true
}
