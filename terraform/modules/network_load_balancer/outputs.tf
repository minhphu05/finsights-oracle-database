output "nlb_id" {
  description = "OCID of the Network Load Balancer"
  value       = oci_network_load_balancer_network_load_balancer.this.id
}

output "public_ip" {
  description = "Public IP address of the Network Load Balancer"
  value       = try([for ip in oci_network_load_balancer_network_load_balancer.this.ip_addresses : ip.ip_address if ip.is_public][0], "")
}
