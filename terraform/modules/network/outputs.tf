output "vcn_id" {
  description = "OCID of the created VCN"
  value       = oci_core_vcn.this.id
}

output "private_subnet_id" {
  description = "OCID of the private database subnet"
  value       = oci_core_subnet.private.id
}

output "security_list_id" {
  description = "OCID of the private security list"
  value       = oci_core_security_list.private.id
}
