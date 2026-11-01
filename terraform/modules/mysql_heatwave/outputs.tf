output "id" {
  description = "OCID of the MySQL DB System"
  value       = oci_mysql_mysql_db_system.this.id
}

output "ip_address" {
  description = "Private IP address of the MySQL DB System"
  value       = oci_mysql_mysql_db_system.this.ip_address
}

output "port" {
  description = "Port for MySQL connection"
  value       = oci_mysql_mysql_db_system.this.port
}

output "port_x" {
  description = "Port for MySQL X Protocol connection"
  value       = oci_mysql_mysql_db_system.this.port_x
}

output "heatwave_cluster_status" {
  description = "State of HeatWave cluster if enabled"
  value       = var.enable_heatwave && length(oci_mysql_heat_wave_cluster.this) > 0 ? oci_mysql_heat_wave_cluster.this[0].state : "DISABLED"
}
