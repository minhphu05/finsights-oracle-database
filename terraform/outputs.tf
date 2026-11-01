# ==============================================================================
# Account 1: Tokyo Outputs (Full Stack)
# ==============================================================================
output "account1_vcn_id" {
  description = "OCID of Account 1 Tokyo VCN"
  value       = module.account1_network.vcn_id
}

output "account1_autonomous_database_id" {
  description = "OCID of Autonomous Database 23ai in Account 1 (Tokyo)"
  value       = var.enable_autonomous_database ? module.account1_autonomous_database[0].id : null
}

output "account1_autonomous_database_name" {
  description = "Database service name for Account 1"
  value       = var.enable_autonomous_database ? module.account1_autonomous_database[0].db_name : null
}

output "account1_autonomous_database_connection_strings" {
  description = "Connection strings and TNS aliases for Account 1 Autonomous Database"
  value       = var.enable_autonomous_database ? module.account1_autonomous_database[0].connection_strings : null
}

output "account1_autonomous_database_service_console_url" {
  description = "URL to the Oracle Database Actions / SQL Developer Web service console (Account 1)"
  value       = var.enable_autonomous_database ? module.account1_autonomous_database[0].service_console_url : null
}

output "account1_autonomous_database_wallet_base64" {
  description = "Base64-encoded client credential wallet zip for Account 1 (sensitive)"
  value       = var.enable_autonomous_database ? module.account1_autonomous_database[0].wallet_base64 : null
  sensitive   = true
}

output "account1_object_storage_bucket_name" {
  description = "Name of Account 1 Object Storage bucket (Tokyo)"
  value       = var.enable_object_storage ? module.account1_object_storage[0].bucket_name : null
}

output "account1_object_storage_namespace" {
  description = "Object Storage namespace for Account 1"
  value       = var.enable_object_storage ? module.account1_object_storage[0].namespace : null
}

output "account1_mysql_id" {
  description = "OCID of MySQL DB System in Account 1 (Tokyo)"
  value       = var.enable_mysql ? module.account1_mysql_heatwave[0].id : null
}

output "account1_mysql_private_ip" {
  description = "Private IP address of MySQL DB System in Account 1 (Tokyo)"
  value       = var.enable_mysql ? module.account1_mysql_heatwave[0].ip_address : null
}

output "account1_mysql_port" {
  description = "Port for MySQL connection in Account 1 (default 3306)"
  value       = var.enable_mysql ? module.account1_mysql_heatwave[0].port : null
}

output "account1_mysql_heatwave_status" {
  description = "Status of MySQL HeatWave cluster in Account 1 (Tokyo)"
  value       = var.enable_mysql ? module.account1_mysql_heatwave[0].heatwave_cluster_status : null
}

output "account1_mysql_public_ip" {
  description = "Public IP of Network Load Balancer forwarding to MySQL in Account 1 (Tokyo) for DBeaver/external clients"
  value       = var.enable_mysql && var.enable_mysql_nlb ? module.account1_mysql_nlb[0].public_ip : null
}

# ==============================================================================
# Account 2: Singapore Outputs (Full Stack)
# ==============================================================================
output "account2_vcn_id" {
  description = "OCID of Account 2 Singapore VCN"
  value       = var.enable_account2 ? module.account2_network[0].vcn_id : null
}

output "account2_autonomous_database_id" {
  description = "OCID of Autonomous Database 23ai in Account 2 (Singapore)"
  value       = var.enable_account2 && var.enable_autonomous_database ? module.account2_autonomous_database[0].id : null
}

output "account2_autonomous_database_name" {
  description = "Database service name for Account 2"
  value       = var.enable_account2 && var.enable_autonomous_database ? module.account2_autonomous_database[0].db_name : null
}

output "account2_autonomous_database_connection_strings" {
  description = "Connection strings and TNS aliases for Account 2 Autonomous Database"
  value       = var.enable_account2 && var.enable_autonomous_database ? module.account2_autonomous_database[0].connection_strings : null
}

output "account2_autonomous_database_service_console_url" {
  description = "URL to the Oracle Database Actions / SQL Developer Web service console (Account 2)"
  value       = var.enable_account2 && var.enable_autonomous_database ? module.account2_autonomous_database[0].service_console_url : null
}

output "account2_autonomous_database_wallet_base64" {
  description = "Base64-encoded client credential wallet zip for Account 2 (sensitive)"
  value       = var.enable_account2 && var.enable_autonomous_database ? module.account2_autonomous_database[0].wallet_base64 : null
  sensitive   = true
}

output "account2_object_storage_bucket_name" {
  description = "Name of Account 2 Object Storage bucket (Singapore)"
  value       = var.enable_account2 && var.enable_object_storage ? module.account2_object_storage[0].bucket_name : null
}

output "account2_object_storage_namespace" {
  description = "Object Storage namespace for Account 2"
  value       = var.enable_account2 && var.enable_object_storage ? module.account2_object_storage[0].namespace : null
}

output "account2_mysql_id" {
  description = "OCID of MySQL DB System in Account 2 (Singapore)"
  value       = var.enable_account2 && var.enable_mysql ? module.account2_mysql_heatwave[0].id : null
}

output "account2_mysql_private_ip" {
  description = "Private IP address of MySQL DB System in Account 2 (Singapore)"
  value       = var.enable_account2 && var.enable_mysql ? module.account2_mysql_heatwave[0].ip_address : null
}

output "account2_mysql_port" {
  description = "Port for MySQL connection in Account 2 (default 3306)"
  value       = var.enable_account2 && var.enable_mysql ? module.account2_mysql_heatwave[0].port : null
}

output "account2_mysql_heatwave_status" {
  description = "Status of MySQL HeatWave cluster in Account 2 (Singapore)"
  value       = var.enable_account2 && var.enable_mysql ? module.account2_mysql_heatwave[0].heatwave_cluster_status : null
}

output "account2_mysql_public_ip" {
  description = "Public IP of Network Load Balancer forwarding to MySQL in Account 2 (Singapore) for DBeaver/external clients"
  value       = var.enable_account2 && var.enable_mysql && var.enable_mysql_nlb ? module.account2_mysql_nlb[0].public_ip : null
}
