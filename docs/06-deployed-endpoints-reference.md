# Thông tin kết nối các tài nguyên Oracle Cloud (Tokyo & Singapore)

Hạ tầng Oracle Cloud cho **Finsights** đã được khởi tạo thành công 100% trên cả 2 tài khoản (Tokyo - Primary và Singapore - Secondary).

Tài liệu này tổng hợp toàn bộ thông tin kết nối, địa chỉ IP, namespace và hướng dẫn sử dụng.

---

## 1. Tổng quan tài nguyên đã triển khai

| Tài nguyên | Account 1 (Tokyo - Primary) | Account 2 (Singapore - Secondary) | Trạng thái |
| :--- | :--- | :--- | :--- |
| **Autonomous Database 23ai (Vector DB)** | `finsightsvec1`<br>Port `1522` (mTLS) | `finsightsvec2`<br>Port `1522` (mTLS) | **AVAILABLE** |
| **MySQL Database System (Free)** | `10.100.1.139:3306` | `10.200.1.76:3306` | **AVAILABLE** |
| **Object Storage Bucket (10 GB)** | `finsights-data-assets-tokyo`<br>Namespace: `nryqf437jjy5` | `finsights-data-assets-singapore`<br>Namespace: `axrxyxi3tkjc` | **AVAILABLE** |
| **VCN & Private Subnet** | VCN: `10.100.0.0/16`<br>Subnet: `10.100.1.0/24` | VCN: `10.200.0.0/16`<br>Subnet: `10.200.1.0/24` | **AVAILABLE** |

---

## 2. Chi tiết kết nối Account 1 (Tokyo - Primary)

### A. Autonomous Database 23ai (`finsightsvec1`)
* **OCID:** `ocid1.autonomousdatabase.oc1.ap-tokyo-1.anxhiljrerrfgaqa64aarpr4qbwd7dso6aogjkxxlzumi2p4zgfdp7wcpeqa`
* **Workload:** OLTP + AI Vector Search
* **User mặc định:** `ADMIN`
* **Mật khẩu:** Secret `ADB_ADMIN_PASSWORD` (tối thiểu 12 ký tự)
* **Phương thức xác thực:** Mutual TLS (mTLS Wallet `cwallet.sso`)
* **Connection Strings:**
  * **HIGH (Chạy batch, vector indexing):**
    ```
    (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.ap-tokyo-1.oraclecloud.com))(connect_data=(service_name=g8032bdda4e90e0_finsightsvec1_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))
    ```
  * **MEDIUM (Khuyên dùng cho API / Backend thông thường):**
    ```
    (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.ap-tokyo-1.oraclecloud.com))(connect_data=(service_name=g8032bdda4e90e0_finsightsvec1_medium.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))
    ```
  * **LOW (Tác vụ nền, report nhẹ):**
    ```
    (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.ap-tokyo-1.oraclecloud.com))(connect_data=(service_name=g8032bdda4e90e0_finsightsvec1_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))
    ```

### B. MySQL Database System (`finsights-mysql-db-tokyo`)
* **OCID:** `ocid1.mysqldbsystem.oc1.ap-tokyo-1.aaaaaaaah5gfufbc65o46f4vwwvpba5f7sta4ls6wdyp6lkv6aa56bh25b3q`
* **Private IP:** `10.100.1.139`
* **Port:** `3306` (giao thức MySQL tiêu chuẩn), `33060` (X-Protocol)
* **Username:** `finsightsadmin`
* **Mật khẩu:** Secret `MYSQL_ADMIN_PASSWORD`
* **Shape:** `MySQL.Free` (1 ECPU, 50 GB storage)

### C. Object Storage Bucket (`finsights-data-assets-tokyo`)
* **Bucket Name:** `finsights-data-assets-tokyo`
* **Namespace:** `nryqf437jjy5`
* **Tier:** Standard (Always Free 10 GB)
* **S3-Compatible Endpoint:**
  ```
  https://nryqf437jjy5.compat.objectstorage.ap-tokyo-1.oraclecloud.com
  ```

---

## 3. Chi tiết kết nối Account 2 (Singapore - Secondary)

### A. Autonomous Database 23ai (`finsightsvec2`)
* **OCID:** `ocid1.autonomousdatabase.oc1.ap-singapore-1.anzwsljr362vtaqatu2yrmm3xjteylxkfed22fsw327qnlfa7cyhu3s7wqya`
* **Workload:** OLTP + AI Vector Search
* **User mặc định:** `ADMIN`
* **Mật khẩu:** Secret `ADB_ADMIN_PASSWORD`
* **Connection Strings:**
  * **HIGH:**
    ```
    (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.ap-singapore-1.oraclecloud.com))(connect_data=(service_name=g2ae9da0546a642_finsightsvec2_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))
    ```
  * **MEDIUM:**
    ```
    (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.ap-singapore-1.oraclecloud.com))(connect_data=(service_name=g2ae9da0546a642_finsightsvec2_medium.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))
    ```
  * **LOW:**
    ```
    (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.ap-singapore-1.oraclecloud.com))(connect_data=(service_name=g2ae9da0546a642_finsightsvec2_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))
    ```

### B. MySQL Database System (`finsights-mysql-db-singapore`)
* **OCID:** `ocid1.mysqldbsystem.oc1.ap-singapore-1.aaaaaaaamkqnb7r7og4jfjw4okwlmv6ga2g32mxz6zmvod7gcsorsbz3a7uq`
* **Private IP:** `10.200.1.76`
* **Port:** `3306`
* **Username:** `finsightsadmin`
* **Mật khẩu:** Secret `MYSQL_ADMIN_PASSWORD`
* **Shape:** `MySQL.Free` (1 ECPU, 50 GB storage)

### C. Object Storage Bucket (`finsights-data-assets-singapore`)
* **Bucket Name:** `finsights-data-assets-singapore`
* **Namespace:** `axrxyxi3tkjc`
* **Tier:** Standard (Always Free 10 GB)
* **S3-Compatible Endpoint:**
  ```
  https://axrxyxi3tkjc.compat.objectstorage.ap-singapore-1.oraclecloud.com
  ```

---

## 4. Cách tải Wallet của Autonomous Database kết nối từ App / Backend

### Qua Terraform Outputs:
Mỗi lần chạy thành công, GitHub Actions workflow đã lưu file `terraform.tfstate` vào Artifact và Cache. Bạn có thể lấy chuỗi base64 của Wallet:

```bash
# Decode wallet base64 thành file zip
echo "<base64_string_tu_output>" | base64 -d > wallet.zip
unzip wallet.zip -d ./wallet
```

Bên trong thư mục `wallet/` sẽ có:
* `tnsnames.ora`: Định nghĩa các TNS alias (`finsightsvec1_high`, `finsightsvec1_medium`, ...)
* `sqlnet.ora`: Cấu hình trỏ đường dẫn tới file chứng chỉ
* `cwallet.sso` & `ewallet.p12`: Chứng chỉ số mã hóa mTLS

### Ví dụ kết nối Python (oracledb) với Vector Search:
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
