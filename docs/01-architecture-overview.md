# Kiến Trúc Hạ Tầng Cơ Sở Dữ Liệu Finsights trên Oracle Cloud (OCI) - Multi-Tenancy Đa Tài Khoản

Tài liệu này mô tả chi tiết kiến trúc, các dịch vụ PaaS/SaaS và hạn mức **Always Free** của Oracle Cloud được tận dụng song song trên **cả 2 tài khoản (Account 1 Tokyo & Account 2 Singapore)** để phục vụ nền tảng dữ liệu tài chính **Finsights**.

---

## 1. Mục Tiêu & Ranh Giới Hạ Tầng

- **Không tạo máy ảo Compute (Zero VMs):** Toàn bộ workload tính toán, API backend, frontend và Ingress controller được host trên cụm 2 VPS Ubuntu (quản lý độc lập tại `finsights-infrastructure`).
- **Mô hình nhân bản tài nguyên đối xứng (Mirrored Full-Stack Architecture):** 
  - Thay vì chia nhỏ, **cả Account 1 (Tokyo) và Account 2 (Singapore) đều được khởi tạo đầy đủ mọi tài nguyên dữ liệu độc lập**, tận dụng tối đa hạn mức Always Free riêng biệt của từng tài khoản.

---

## 2. Bảng Phân Bổ Tài Nguyên Song Song Trên 2 Account

| Thành phần | Account 1 (Tokyo `ap-tokyo-1`) | Account 2 (Singapore `ap-singapore-1`) | Hạn mức Always Free |
|---|---|---|---|
| **Mạng nội bộ** | VCN `10.100.0.0/16` + Private Subnet | VCN `10.200.0.0/16` + Private Subnet | Miễn phí VCN & Gateway |
| **AI Vector Database** | Autonomous DB 23ai (`finsightsvec1`) | Autonomous DB 23ai (`finsightsvec2`) | **Mỗi tài khoản 2 ECPUs & 20 GB Free** |
| **Object Storage** | Bucket `finsights-data-assets-tokyo` | Bucket `finsights-data-assets-singapore`| **Mỗi tài khoản 10 GB Standard Free** |
| **Relational Database** | MySQL DB System (`finsights-mysql-db-tokyo`) | MySQL DB System (`finsights-mysql-db-singapore`) | Managed PaaS trong Private Subnet |
| **In-Memory Analytics**| HeatWave Cluster (Tùy chọn) | HeatWave Cluster (Tùy chọn) | In-Memory MPP Acceleration |

---

## 3. Lợi Ích Của Mô Hình Đa Tài Khoản Song Song

1. **Gấp đôi tài nguyên Always Free vĩnh viễn:**
   - **4 ECPUs và 40 GB lưu trữ Vector Database** (chia đều cho 2 database 23ai).
   - **20 GB lưu trữ Object Storage chuẩn Standard** tốc độ cao.
2. **Khả năng chịu lỗi & Dự phòng thảm họa (Disaster Recovery / Geo-Redundancy):**
   - Dữ liệu có thể được sao lưu chéo giữa Tokyo và Singapore.
   - Nếu một vùng gặp sự cố mạng cáp quang biển, vùng còn lại vẫn hoạt động 100% độc lập.
3. **Phân tách môi trường linh hoạt:**
   - Bạn có thể dùng Account 1 làm Production chính và Account 2 làm Staging/Data Warehouse/Analytics, hoặc chạy song song Active-Active.
