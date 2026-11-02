output "topic_id" {
  description = "OCID of the ONS notification topic"
  value       = oci_ons_notification_topic.alerts.id
}

output "management_agent_install_key" {
  description = "Management Agent Install Key to install OCI agent on external VPS nodes"
  value       = oci_management_agent_management_agent_install_key.this.key
  sensitive   = true
}

output "management_agent_install_key_id" {
  description = "OCID of the Management Agent Install Key"
  value       = oci_management_agent_management_agent_install_key.this.id
}
