# Thông tin kết nối các tài nguyên Oracle Cloud (Tokyo & Singapore)

Hạ tầng Oracle Cloud cho **Finsights** đã được khởi tạo hoàn chỉnh 100% trên cả 2 tài khoản (Tokyo - Primary và Singapore - Secondary).

Tài liệu này tổng hợp toàn bộ thông tin kết nối, địa chỉ Public IP, Private IP, namespace và hướng dẫn kết nối DBeaver / Code.

---

## 1. Tổng quan tài nguyên đã triển khai

| Tài nguyên | Account 1 (Tokyo - Primary) | Account 2 (Singapore - Secondary) | Trạng thái |
| :--- | :--- | :--- | :--- |
| **MySQL Public Endpoint (DBeaver & VPS)** | **`161.33.181.173:3306`** (NLB Public IP) | **`129.221.137.201:3306`** (NLB Public IP) | **AVAILABLE (Đã test port 3306 thành công)** |
| **MySQL Private IP (Nội bộ VCN)** | `10.100.1.139:3306` | `10.200.1.76:3306` | **AVAILABLE** |
| **Autonomous Database 23ai (Vector DB)** | `finsightsvec1`<br>Port `1522` (mTLS Wallet) | `finsightsvec2`<br>Port `1522` (mTLS Wallet) | **AVAILABLE** |
| **Object Storage Bucket (20 GB Free)** | `finsights-data-assets-tokyo`<br>Namespace: `nryqf437jjy5` | `finsights-data-assets-singapore`<br>Namespace: `axrxyxi3tkjc` | **AVAILABLE** |
| **Mạng VCN & Subnet** | VCN: `10.100.0.0/16`<br>Public: `10.100.0.0/24`<br>Private: `10.100.1.0/24` | VCN: `10.200.0.0/16`<br>Public: `10.200.0.0/24`<br>Private: `10.200.1.0/24` | **AVAILABLE** |

---

## 2. Hướng dẫn kết nối DBeaver vào MySQL trực tiếp

Bạn có thể kết nối thẳng từ DBeaver trên máy tính (Mac) hoặc từ 2 VPS nodes mà **KHÔNG CẦN SSH Tunnel**:

### Kết nối MySQL Tokyo:
* **Host:** `161.33.181.173`
* **Port:** `3306`
* **Database:** `finsights` (hoặc để trống)
* **Username:** `finsightsadmin`
* **Password:** Mật khẩu secret `MYSQL_ADMIN_PASSWORD` của bạn
* Bấm **Test Connection** -> Kết nối thành công!

### Kết nối MySQL Singapore:
* **Host:** `129.221.137.201`
* **Port:** `3306`
* **Database:** `finsights` (hoặc để trống)
* **Username:** `finsightsadmin`
* **Password:** Mật khẩu secret `MYSQL_ADMIN_PASSWORD` của bạn
* Bấm **Test Connection** -> Kết nối thành công!

---

## 3. Chi tiết kết nối Account 1 (Tokyo - Primary)

### A. MySQL Database System & NLB (`finsights-mysql-db-tokyo`)
* **Public IP (NLB Forwarding):** `161.33.181.173`
* **Private IP (Nội bộ):** `10.100.1.139`
* **Port:** `3306`
* **Username:** `finsightsadmin`
* **Mật khẩu:** Secret `MYSQL_ADMIN_PASSWORD`
* **Shape:** `MySQL.Free` (1 ECPU, 50 GB storage)

### B. Autonomous Database 23ai (`finsightsvec1`)
* **OCID:** `ocid1.autonomousdatabase.oc1.ap-tokyo-1.anxhiljrerrfgaqa64aarpr4qbwd7dso6aogjkxxlzumi2p4zgfdp7wcpeqa`
* **Workload:** OLTP + AI Vector Search (Native 23ai)
* **User:** `ADMIN`
* **Mật khẩu:** Secret `ADB_ADMIN_PASSWORD`
* **Phương thức xác thực:** Mutual TLS (mTLS Wallet `cwallet.sso`)
* **Connection String (MEDIUM - Khuyên dùng):**
  ```
  (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.ap-tokyo-1.oraclecloud.com))(connect_data=(service_name=g8032bdda4e90e0_finsightsvec1_medium.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))
  ```

### C. Object Storage Bucket (`finsights-data-assets-tokyo`)
* **Bucket Name:** `finsights-data-assets-tokyo`
* **Namespace:** `nryqf437jjy5`
* **Tier:** Standard (Always Free 20 GB)
* **S3-Compatible Endpoint:**
  ```
  https://nryqf437jjy5.compat.objectstorage.ap-tokyo-1.oraclecloud.com
  ```

---

## 4. Chi tiết kết nối Account 2 (Singapore - Secondary)

### A. MySQL Database System & NLB (`finsights-mysql-db-singapore`)
* **Public IP (NLB Forwarding):** `129.221.137.201`
* **Private IP (Nội bộ):** `10.200.1.76`
* **Port:** `3306`
* **Username:** `finsightsadmin`
* **Mật khẩu:** Secret `MYSQL_ADMIN_PASSWORD`
* **Shape:** `MySQL.Free` (1 ECPU, 50 GB storage)

### B. Autonomous Database 23ai (`finsightsvec2`)
* **OCID:** `ocid1.autonomousdatabase.oc1.ap-singapore-1.anzwsljr362vtaqatu2yrmm3xjteylxkfed22fsw327qnlfa7cyhu3s7wqya`
* **Workload:** OLTP + AI Vector Search (Native 23ai)
* **User:** `ADMIN`
* **Mật khẩu:** Secret `ADB_ADMIN_PASSWORD`
* **Connection String (MEDIUM - Khuyên dùng):**
  ```
  (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.ap-singapore-1.oraclecloud.com))(connect_data=(service_name=g2ae9da0546a642_finsightsvec2_medium.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))
  ```

### C. Object Storage Bucket (`finsights-data-assets-singapore`)
* **Bucket Name:** `finsights-data-assets-singapore`
* **Namespace:** `axrxyxi3tkjc`
* **Tier:** Standard (Always Free 20 GB)
* **S3-Compatible Endpoint:**
  ```
  https://axrxyxi3tkjc.compat.objectstorage.ap-singapore-1.oraclecloud.com
  ```

---

## 5. Ví dụ kết nối Python (oracledb) với AI Vector Search (23ai)

```python
import oracledb

connection = oracledb.connect(
    user="ADMIN",
    password="<ADB_ADMIN_PASSWORD>",
    dsn="finsightsvec1_medium",
    config_dir="/path/to/wallet",
    wallet_location="/path/to/wallet",
    wallet_password="<ADB_ADMIN_PASSWORD>"
)

with connection.cursor() as cursor:
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS finsights_embeddings (
            id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
            content VARCHAR2(4000),
            v_embedding VECTOR(1536, FLOAT32)
        )
    """)
    print("Connected to Autonomous Database 23ai Vector successfully!")
```
