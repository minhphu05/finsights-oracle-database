# Hướng Dẫn: Sử Dụng Oracle Autonomous Database 23ai Làm AI Vector Database

**Oracle Database 23ai** là phiên bản cơ sở dữ liệu tích hợp sẵn tính năng **AI Vector Search** nguyên bản (native), cho phép lưu trữ và tìm kiếm vector tương đồng (similarity search) cùng với dữ liệu quan hệ và JSON trong một hệ quản trị duy nhất.

---

## 1. Kết Nối Vào Autonomous Database

### 1.1. Tải và Giải Nén Wallet Client
Sau khi chạy Terraform thành công, file wallet chứa chứng chỉ bảo mật mTLS có thể tải về từ console hoặc xuất ra từ Terraform output:
```bash
# Xuất wallet từ Terraform output (nếu cần)
terraform output -raw autonomous_database_wallet_base64 | base64 --decode > wallet.zip
unzip wallet.zip -d ./wallet/
```

### 1.2. Kết Nối bằng Python (`oracledb`)
Cài đặt thư viện `oracledb`:
```bash
pip install oracledb
```

Mẫu code kết nối sử dụng Wallet mTLS:
```python
import oracledb

# Khởi tạo kết nối qua Wallet
connection = oracledb.connect(
    user="ADMIN",
    password="<your-adb-admin-password>",
    dsn="finsightsvec_high",
    config_dir="./wallet",
    wallet_location="./wallet",
    wallet_password="<your-adb-admin-password>"
)

print("Kết nối Oracle 23ai Vector DB thành công! Phiên bản:", connection.version)
```

---

## 2. Tạo Bảng & Lưu Trữ Vector Embeddings

### 2.1. Tạo Bảng Tài Liệu Tài Chính với Cột `VECTOR`
Ví dụ tạo bảng lưu trữ các phân tích tài chính với embedding 1536 chiều (chuẩn OpenAI `text-embedding-3-small` hoặc `text-embedding-ada-002`):

```sql
CREATE TABLE financial_document_chunks (
    id            VARCHAR2(64) PRIMARY KEY,
    ticker        VARCHAR2(10) NOT NULL,
    fiscal_year   NUMBER(4),
    chunk_text    CLOB NOT NULL,
    metadata_json JSON,
    embedding     VECTOR(1536, FLOAT32),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2.2. Tạo Chỉ Mục Vector (HNSW Index) để Tăng Tốc Tìm Kiếm
Oracle 23ai hỗ trợ chỉ mục **HNSW (Hierarchical Navigable Small World)** giúp tìm kiếm độ tương đồng với tốc độ cực nhanh:

```sql
CREATE VECTOR INDEX idx_fin_doc_hnsw 
ON financial_document_chunks (embedding)
ORGANIZATION INMEMORY NEIGHBOR GRAPH
DISTANCE COSINE
WITH TARGET ACCURACY 95;
```

---

## 3. Tìm Kiếm Tương Đồng Vector (Semantic Search)

Tìm 5 đoạn văn bản liên quan nhất đến câu hỏi của người dùng bằng hàm khoảng cách `VECTOR_DISTANCE` với độ đo `COSINE`:

```sql
SELECT id, ticker, chunk_text,
       VECTOR_DISTANCE(embedding, :query_vector, COSINE) AS distance
FROM financial_document_chunks
WHERE ticker = 'VNM'
ORDER BY VECTOR_DISTANCE(embedding, :query_vector, COSINE)
FETCH FIRST 5 ROWS ONLY;
```

---

## 4. Tích Hợp với LangChain / LlamaIndex

Oracle cung cấp tích hợp chính thức `langchain-community` và `llama-index-vector-stores-oracledb`:

```python
from langchain_community.vectorstores import OracleVS
from langchain_community.embeddings import OpenAIEmbeddings

embeddings = OpenAIEmbeddings(model="text-embedding-3-small")

vector_store = OracleVS(
    client=connection,
    table_name="financial_document_chunks",
    embedding_function=embeddings,
    distance_strategy="COSINE"
)

# Tìm kiếm ngữ nghĩa
results = vector_store.similarity_search("Doanh thu quý 3 năm 2026 tăng trưởng ra sao?", k=4)
for doc in results:
    print(doc.page_content)
```
