terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

# 1. Oracle Notification Service (ONS) Topic for Alarms
resource "oci_ons_notification_topic" "alerts" {
  compartment_id = var.compartment_id
  name           = "${var.name_prefix}-alerts-topic"
  description    = "Centralized alerting topic for Finsights database & infrastructure monitoring"
  freeform_tags  = var.tags
}

# 2. Metric Alarm: Autonomous Database High CPU
resource "oci_monitoring_alarm" "adb_cpu" {
  count                 = var.adb_id != "" ? 1 : 0
  compartment_id        = var.compartment_id
  metric_compartment_id = var.compartment_id
  display_name          = "${var.name_prefix}-adb-cpu-alarm"
  namespace             = "oci_autonomous_database"
  query                 = "CpuUtilization[1m]{resourceId = \"${var.adb_id}\"}.mean() > 85"
  severity              = "CRITICAL"
  destinations          = [oci_ons_notification_topic.alerts.id]
  is_enabled            = true
  body                  = "Autonomous Database 23ai (${var.name_prefix}) CPU utilization exceeded 85% for 1 minute."
  freeform_tags         = var.tags
}

# 3. Metric Alarm: MySQL High CPU
resource "oci_monitoring_alarm" "mysql_cpu" {
  count                 = var.mysql_id != "" ? 1 : 0
  compartment_id        = var.compartment_id
  metric_compartment_id = var.compartment_id
  display_name          = "${var.name_prefix}-mysql-cpu-alarm"
  namespace             = "oci_mysql_database"
  query                 = "CpuUtilization[1m]{resourceId = \"${var.mysql_id}\"}.mean() > 85"
  severity              = "CRITICAL"
  destinations          = [oci_ons_notification_topic.alerts.id]
  is_enabled            = true
  body                  = "MySQL Database System (${var.name_prefix}) CPU utilization exceeded 85% for 1 minute."
  freeform_tags         = var.tags
}

# 4. Management Agent Install Key for External VPS Monitoring
resource "oci_management_agent_management_agent_install_key" "this" {
  compartment_id = var.compartment_id
  display_name   = "${var.name_prefix}-vps-agent-key"
  is_unlimited   = true
  lifecycle {
    ignore_changes = [
      time_expires
    ]
  }
}
