# Hướng Dẫn: Sử Dụng OCI MySQL Database System & HeatWave

**MySQL Database System** trong Oracle Cloud là dịch vụ cơ sở dữ liệu quan hệ được quản lý hoàn toàn (PaaS). Khi kết hợp với **HeatWave Cluster**, hệ thống có khả năng tăng tốc các truy vấn phân tích dữ liệu tài chính lớn mà không cần tách rời cơ sở dữ liệu OLTP và OLAP.

---

## 1. Kết Nối Vào MySQL Database System

Do MySQL DB System được đặt trong **Private Subnet** (`10.100.1.0/24`) để bảo mật tuyệt đối, bạn có thể kết nối từ các máy chủ Finsights VPS hoặc máy cá nhân qua các phương thức sau:

### 1.1. Kết Nối Trực Tiếp từ Finsights VPS (Trong Cùng Mạng / VPN)
Nếu bạn cấu hình VPN kết nối giữa VPS và OCI VCN:
```bash
mysql -h <mysql_private_ip> -P 3306 -u finsightsadmin -p
```

### 1.2. Kết Nối qua SSH Port Forwarding (SSH Bastion)
Từ máy cá nhân, dùng một máy chủ làm cầu nối SSH tunnel (ví dụ Node 1 hoặc một bastion host):
```bash
ssh -i ~/.ssh/finsights_vps -L 3306:<mysql_private_ip>:3306 -p 26567 root@103.249.117.232
```
Sau đó mở DBeaver / MySQL Workbench kết nối tới:
- **Host:** `127.0.0.1`
- **Port:** `3306`
- **User:** `finsightsadmin`
- **Password:** `<your-mysql-admin-password>`

---

## 2. Kích Hoạt HeatWave Acceleration cho Bảng Dữ Liệu

Khi bạn bật `enable_heatwave = true` trong Terraform, một cụm HeatWave Cluster in-memory sẽ được tạo.

Để nạp một bảng dữ liệu vào bộ nhớ HeatWave nhằm tăng tốc độ truy vấn:

### 2.1. Định Nghĩa Bảng Sử Dụng Secondary Engine `RAPID`
```sql
ALTER TABLE stock_transactions SECONDARY_ENGINE = RAPID;
```

### 2.2. Nạp Dữ Liệu Bảng vào HeatWave
```sql
ALTER TABLE stock_transactions SECONDARY_LOAD;
```

### 2.3. Kiểm Tra Trạng Thái Nạp
```sql
SELECT table_name, load_status 
FROM performance_schema.rpd_tables;
```

---

## 3. Thực Thi Truy Vấn Phân Tích Siêu Tốc

Khi thực hiện các câu lệnh thống kê phức tạp (aggregations, joins, group by lớn trên hàng triệu bản ghi), bộ tối ưu hóa (Optimizer) của MySQL sẽ tự động đẩy truy vấn xuống cụm HeatWave xử lý song song:

```sql
EXPLAIN SELECT ticker, 
               DATE_FORMAT(trade_date, '%Y-%m') AS month,
               SUM(volume) AS total_volume,
               AVG(close_price) AS avg_price
FROM stock_transactions
GROUP BY ticker, month
ORDER BY total_volume DESC;
```
Trong kết quả `EXPLAIN`, bạn sẽ thấy dòng: `Using secondary engine RAPID`. Thời gian thực thi sẽ giảm từ vài giây/phút xuống còn vài chục mili-giây!
