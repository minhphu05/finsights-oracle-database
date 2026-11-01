terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

# 1. Virtual Cloud Network (VCN)
resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_id
  display_name   = "${var.name_prefix}-vcn"
  cidr_blocks    = [var.vcn_cidr]
  dns_label      = "fsdbvcn"
  freeform_tags  = var.tags
}

# 2. Gateways
resource "oci_core_nat_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-nat-gw"
  freeform_tags  = var.tags
}

data "oci_core_services" "all_services" {}

locals {
  all_services_dest = try(
    [for s in data.oci_core_services.all_services.services : s.cidr_block if length(regexall(".*All.*Services.*", s.name)) > 0][0],
    data.oci_core_services.all_services.services[0].cidr_block
  )
  all_services_id = try(
    [for s in data.oci_core_services.all_services.services : s.id if length(regexall(".*All.*Services.*", s.name)) > 0][0],
    data.oci_core_services.all_services.services[0].id
  )
}

resource "oci_core_service_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-service-gw"
  services {
    service_id = local.all_services_id
  }
  freeform_tags = var.tags
}

# 3. Private Route Table
resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-private-rt"

  # Route outbound internet traffic via NAT Gateway
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this.id
    description       = "Default internet route through NAT Gateway"
  }

  # Route Oracle internal services (Object Storage, ADB) via Service Gateway
  route_rules {
    destination       = local.all_services_dest
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.this.id
    description       = "Oracle Services route through Service Gateway"
  }

  freeform_tags = var.tags
}

# 4. Security List for Private Database Subnet
resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-private-sl"

  # Ingress: MySQL traffic (ports 3306 and 33060) from VCN
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    description = "MySQL database traffic from VCN"
    tcp_options {
      min = 3306
      max = 3306
    }
  }

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    description = "MySQL X Protocol from VCN"
    tcp_options {
      min = 33060
      max = 33060
    }
  }

  # Ingress: Oracle SQL*Net / Autonomous DB (port 1521-1522) from VCN
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    description = "Oracle SQL*Net from VCN"
    tcp_options {
      min = 1521
      max = 1522
    }
  }

  # Ingress from allowed external CIDRs (VPS nodes or operator)
  dynamic "ingress_security_rules" {
    for_each = var.allowed_ingress_cidrs
    content {
      protocol    = "6" # TCP
      source      = ingress_security_rules.value
      source_type = "CIDR_BLOCK"
      description = "Allowed database access from external client ${ingress_security_rules.value}"
      tcp_options {
        min = 3306
        max = 3306
      }
    }
  }

  # Allow all outbound traffic from private subnet
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outbound traffic"
  }

  freeform_tags = var.tags
}

# 5. Private Database Subnet
resource "oci_core_subnet" "private" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.this.id
  display_name               = "${var.name_prefix}-private-subnet"
  cidr_block                 = var.private_subnet_cidr
  dns_label                  = "fsdbsub"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
  freeform_tags              = var.tags
}

# 6. Internet Gateway (for Public Subnet & Network Load Balancer)
resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-igw"
  enabled        = true
  freeform_tags  = var.tags
}

# 7. Public Route Table
resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
    description       = "Default internet route through Internet Gateway"
  }

  freeform_tags = var.tags
}

# 8. Security List for Public Subnet (Network Load Balancer)
resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-public-sl"

  # Ingress MySQL port 3306 from anywhere (protected by MySQL authentication)
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    description = "MySQL access via Network Load Balancer"
    tcp_options {
      min = 3306
      max = 3306
    }
  }

  # Allow all outbound
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outbound traffic"
  }

  freeform_tags = var.tags
}

# 9. Public Subnet (Hosts Network Load Balancer)
resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.this.id
  display_name               = "${var.name_prefix}-public-subnet"
  cidr_block                 = var.public_subnet_cidr
  dns_label                  = "fspubsub"
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  freeform_tags              = var.tags
}
