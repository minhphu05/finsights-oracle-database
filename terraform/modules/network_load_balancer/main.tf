terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

# 1. Flexible Network Load Balancer (Public, Always Free 1 instance per tenancy)
resource "oci_network_load_balancer_network_load_balancer" "this" {
  compartment_id                 = var.compartment_id
  display_name                   = var.display_name
  subnet_id                      = var.subnet_id
  is_private                     = false
  is_preserve_source_destination = false
  freeform_tags                  = var.tags

  lifecycle {
    ignore_changes = [
      defined_tags
    ]
  }
}

# 2. Backend Set for MySQL
resource "oci_network_load_balancer_backend_set" "this" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  name                     = "mysql-backend-set"
  policy                   = "FIVE_TUPLE"
  is_preserve_source       = false

  health_checker {
    protocol = "TCP"
    port     = 3306
    retries  = 3
  }
}

# 3. Backend pointing to MySQL Private IP
resource "oci_network_load_balancer_backend" "this" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  backend_set_name         = oci_network_load_balancer_backend_set.this.name
  name                     = "mysql-backend"
  port                     = 3306
  ip_address               = var.target_private_ip
}

# 4. Listener on port 3306
resource "oci_network_load_balancer_listener" "this" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  name                     = "mysql-listener"
  default_backend_set_name = oci_network_load_balancer_backend_set.this.name
  port                     = 3306
  protocol                 = "TCP"
}
