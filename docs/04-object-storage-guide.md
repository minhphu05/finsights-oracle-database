# Hướng Dẫn: Sử Dụng OCI Object Storage (S3-Compatible)

**OCI Object Storage** cung cấp khả năng lưu trữ đối tượng bền vững, bảo mật và chi phí cực thấp (với **10 GB Standard vĩnh viễn miễn phí** trong Always Free Tier).

---

## 1. Thông Tin Bucket Được Khởi Tạo

### A. Account 1 (Tokyo - Primary)
- **Bucket Name:** `finsights-data-assets-tokyo`
- **Tenancy Namespace:** `nryqf437jjy5`
- **Region:** `ap-tokyo-1`
- **Storage Tier:** `Standard` (Always Free 20 GB)
- **Access Type:** `NoPublicAccess`
- **S3 Endpoint:** `https://nryqf437jjy5.compat.objectstorage.ap-tokyo-1.oraclecloud.com`

### B. Account 2 (Singapore - Secondary)
- **Bucket Name:** `finsights-data-assets-singapore`
- **Tenancy Namespace:** `axrxyxi3tkjc`
- **Region:** `ap-singapore-1`
- **Storage Tier:** `Standard` (Always Free 20 GB)
- **Access Type:** `NoPublicAccess`
- **S3 Endpoint:** `https://axrxyxi3tkjc.compat.objectstorage.ap-singapore-1.oraclecloud.com`

---

## 2. Kết Nối Bằng Chuẩn Amazon S3 API (S3-Compatible)

OCI Object Storage hỗ trợ chuẩn API tương thích hoàn toàn với AWS S3. Bạn có thể sử dụng bất kỳ thư viện nào (`boto3`, `@aws-sdk/client-s3`, MinIO Client `mc`) để thao tác.

### 2.1. Lấy Customer Secret Key (S3 Credentials)
1. Đăng nhập OCI Console.
2. Bấm vào icon **Profile** ở góc trên cùng bên phải > **My profile**.
3. Ở menu bên trái, chọn **Customer secret keys**.
4. Bấm **Generate secret key**, đặt tên ví dụ `finsights-s3-key`.
5. Lưu lại **Access Key** và **Secret Key**.

### 2.2. Kết Nối Bằng Python (`boto3`)

```python
import boto3

# Lấy namespace từ terraform output: terraform output object_storage_namespace
NAMESPACE = "<your-tenancy-namespace>"
REGION = "ap-tokyo-1"  # hoặc ap-singapore-1

s3_client = boto3.client(
    "s3",
    aws_access_key_id="<your-access-key>",
    aws_secret_access_key="<your-secret-key>",
    endpoint_url=f"https://{NAMESPACE}.compat.objectstorage.{REGION}.oraclecloud.com"
)

# Upload file báo cáo tài chính
s3_client.upload_file(
    Filename="financial_report_2026.pdf",
    Bucket="finsights-data-assets",
    Key="reports/2026/VNM_Q3.pdf"
)

# Download file
s3_client.download_file(
    Bucket="finsights-data-assets",
    Key="reports/2026/VNM_Q3.pdf",
    Filename="./downloaded_report.pdf"
)
```

---

## 3. Tạo Pre-Authenticated Request (PAR) Để Chia Sẻ Link Tạm Thời

Pre-Authenticated Request cho phép người dùng hoặc hệ thống khác tải/tải lên file mà không cần tài khoản OCI.

Tạo link tải file có hạn sử dụng qua OCI CLI:
```bash
oci os preauth-request create \
  --bucket-name finsights-data-assets \
  --name "temp-download-link" \
  --access-type ObjectRead \
  --object-name "reports/2026/VNM_Q3.pdf" \
  --time-expires 2026-12-31T23:59:59Z
```
Output sẽ trả về đường link trực tiếp (URL) để người dùng tải file.
