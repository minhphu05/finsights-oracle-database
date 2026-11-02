# Oracle Cloud Monitoring & Alerting Guide

## 1. Tổng quan Kiến trúc Giám sát (Monitoring Architecture)

Thay vì phải tự vận hành cụm **ELK (Elasticsearch - Logstash - Kibana)** hoặc **PLG (Prometheus/Loki/Grafana)** tiêu tốn nhiều RAM/CPU trên 2 VPS (vốn chỉ có tài nguyên giới hạn), hệ thống **Finsights** tận dụng trực tiếp nền tảng **OCI Monitoring & Management Service** Always Free của Oracle Cloud.

```
       +-----------------------------------------------------------+
       |                  Oracle Cloud Infrastructure              |
       |                                                           |
       |  +--------------------+         +-----------------------+ |
       |  | Autonomous DB 23ai |         |   MySQL DB System     | |
       |  |  (Built-in Metrics)|         |  (Built-in Metrics)   | |
       |  +---------+----------+         +-----------+-----------+ |
       |            |                                |             |
       |            +---------------+----------------+             |
       |                            |                              |
       |                            v                              |
       |               +-------------------------+                 |
       |               |  OCI Monitoring Service |                 |
       |               | - Service Metrics       |                 |
       |               | - Custom Metrics        |                 |
       |               | - Built-in Alarms       |                 |
       |               | - OCI Dashboards (UI)   |                 |
       |               +------------+------------+                 |
       |                            |                              |
       |                            v                              |
       |               +-------------------------+                 |
       |               |  OCI Notification (ONS) |                 |
       |               | (Email / Slack / Webhook|                 |
       |               +-------------------------+                 |
       +----------------------------^------------------------------+
                                    |
          (OCI Management Agent / Custom Prometheus Ingestion)
                                    |
       +----------------------------+------------------------------+
       |                    Finsights VPS Nodes                    |
       |  - Node 1 (Control Plane: 103.249.117.232)                |
       |  - Node 2 (Worker + DB:   103.249.117.201)                |
       |  - Node Exporter / K3s Metrics Server                     |
       +-----------------------------------------------------------+
```

### Lợi ích vượt trội so với ELK / PLG tự host:
1. **Tiết kiệm 100% RAM VPS**: Elasticsearch và Prometheus/Loki thường ngốn từ 2GB - 4GB RAM. Sử dụng OCI UI giải phóng toàn bộ RAM này cho K3s and Core Application pods.
2. **Native OCI Telemetry**: Metrics của Autonomous Database 23ai và MySQL (CPU, Memory, Storage, Active Sessions, Query Latency) được thu thập tự động mà không cần agent trung gian.
3. **Always Free Dashboards & Alarms**: Miễn phí trọn đời cho Metric Queries, Custom Dashboards và Alarms qua Email/Slack (ONS).

---

## 2. Các tài nguyên Terraform đã triển khai

Module `terraform/modules/monitoring` quản lý:
1. **ONS Notification Topic (`oci_ons_notification_topic`)**:
   - `finsights-tokyo-alerts-topic` (Account 1 - Tokyo)
   - `finsights-singapore-alerts-topic` (Account 2 - Singapore)
   - Tiếp nhận thông báo khi có Alarm kích hoạt và đẩy về Email/SMS/Webhook/Slack.
2. **Metric Alarms (`oci_monitoring_alarm`)**:
   - `finsights-tokyo-adb-cpu-alarm` & `finsights-singapore-adb-cpu-alarm`: Cảnh báo khi CPU của Autonomous DB vượt quá 85% trong 1 phút liên tục.
   - `finsights-tokyo-mysql-cpu-alarm` & `finsights-singapore-mysql-cpu-alarm`: Cảnh báo khi CPU của MySQL DB System vượt quá 85% trong 1 phút liên tục.
3. **Management Agent Install Key (`oci_management_agent_management_agent_install_key`)**:
   - Khóa cài đặt OCI Management Agent lên 2 VPS Ubuntu để đẩy metrics hệ điều hành (CPU, RAM, Disk, Network) lên OCI Console UI.

---

## 3. Cách xem Monitoring & Dashboards trên OCI Console

### 3.1. Xem Metrics Database có sẵn
1. Đăng nhập vào OCI Console (Tokyo hoặc Singapore).
2. **Autonomous Database 23ai**:
   - Điều hướng: `Oracle Database` -> `Autonomous Database` -> Chọn DB `finsightsvec1` (hoặc `finsightsvec2`).
   - Chọn mục **Metrics** ở menu bên trái.
   - Xem ngay các biểu đồ thời gian thực: *CPU Utilization*, *Storage Used*, *Active Sessions*, *Database Operations*.
3. **MySQL HeatWave**:
   - Điều hướng: `Databases` -> `MySQL` -> `DB Systems` -> Chọn `finsights-mysql-tokyo`.
   - Chọn **Metrics** để xem: *CPU*, *Memory*, *Disk I/O*, *Current Connections*, *Statement Throughput*.

### 3.2. Tạo OCI Dashboard tùy biến (Custom Unified Dashboard)
1. Trên OCI Console, vào menu `Observability & Management` -> `Monitoring` -> `Dashboards`.
2. Bấm **Create Dashboard**, đặt tên `Finsights-Unified-Observability`.
3. Kéo thả các Widget:
   - **Widget 1**: Autonomous DB CPU & Sessions (Namespace: `oci_autonomous_database`).
   - **Widget 2**: MySQL CPU & Connection count (Namespace: `oci_mysql_database`).
   - **Widget 3**: VPS System Metrics (Namespace: `oci_computeagent` hoặc Custom Namespace).

---

## 4. Hướng dẫn kết nối VPS Nodes lên OCI Monitoring (Management Agent)

Để gửi metrics từ 2 VPS (`103.249.117.232` và `103.249.117.201`) lên OCI Console mà không tốn tài nguyên chạy Grafana:

### Bước 1: Lấy Install Key từ Terraform Output
```bash
cd terraform
terraform output -raw account1_management_agent_install_key
```

### Bước 2: Tải và cài đặt OCI Management Agent trên VPS
Đăng nhập vào VPS và chạy:
```bash
# 1. Tải Agent package (OCI Management Agent)
curl -s -L -o /tmp/oracle-cloud-agent.deb https://objectstorage.ap-tokyo-1.oraclecloud.com/p/.../agent.deb

# 2. Tạo file response cài đặt
cat << 'EOF' > /tmp/input-agent.rsp
ManagementAgentInstallKey = <MANAGEMENT_AGENT_INSTALL_KEY>
EOF

# 3. Kích hoạt agent
sudo systemctl enable --now mgmt_agent
```

### Bước 3: Cấu hình OCI Prometheus Ingestion (Tùy chọn)
Nếu VPS đã chạy `node_exporter` trên port 9100:
- OCI Management Agent có sẵn plugin **Prometheus Emitter**.
- Agent sẽ tự động cạo (scrape) endpoint `http://localhost:9100/metrics` của Node Exporter và đẩy thẳng về **OCI Monitoring Service** (Metric Namespace: `vps_infrastructure`).
- Toàn bộ đồ thị RAM, CPU, Load Average, Disk Usage của 2 VPS sẽ hiển thị trên OCI Console Dashboard!

---

## 5. Cấu hình nhận thông báo qua Email / Slack (ONS Subscription)

Để nhận email khi Database hoặc VPS quá tải:
1. Vào `Developer Services` -> `Application Integration` -> `Notifications`.
2. Chọn Topic: `finsights-tokyo-alerts-topic`.
3. Bấm **Create Subscription**:
   - **Protocol**: `Email` (hoặc `Slack`, `PagerDuty`, `HTTPS (Webhook)`).
   - **Endpoint**: Nhập địa chỉ email của bạn.
4. Kiểm tra hộp thư và bấm **Confirm subscription**.
5. Khi có sự cố vượt ngưỡng (CPU > 85%), OCI sẽ gửi cảnh báo tức thì!
