# Finsights Oracle Database Infrastructure (Multi-Tenancy Mirrored)

This repository provisions and manages cloud database and object storage infrastructure on **Oracle Cloud Infrastructure (OCI)** across **two independent accounts (Account 1 Tokyo & Account 2 Singapore)** for the **Finsights** platform.

Each account provisions an **identical, full suite of managed data engines** to maximize Always Free quotas without cross-region single points of failure:
- **Oracle Autonomous Database 23ai (Always Free):** High-performance transactional and **AI Vector Database** for embeddings, RAG pipelines, and financial semantic search.
- **OCI Object Storage (Always Free):** 10 GB standard storage per account for reports, documents, assets, and backups with S3-compatible API access.
- **MySQL Database System & HeatWave:** Managed MySQL with optional in-memory HeatWave analytics acceleration for high-throughput transactional and OLAP queries.

> **Note:** This repository creates **NO compute VMs** (zero VM instances). All application compute workloads run on the VPS Kubernetes cluster managed in [`finsights-infrastructure`](../finsights-infrastructure/).

---

## 1. Cloud Architecture

```text
 ┌────────────────────────────────────────────────────────────────────────┐
 │                      FINSIGHTS KUBERNETES CLUSTER                     │
 │               (VPS Node 1 & Node 2 via Tailscale VPN)                  │
 └───────────────────┬────────────────────────────────┬───────────────────┘
                     │ (mTLS Port 1522 / Wallet)      │ (Private TCP 3306)
                     ▼                                ▼
 ┌─────────────────────────────────────────┐      ┌─────────────────────────────────────────┐
 │   ACCOUNT 1: TOKYO (NRT)                │      │   ACCOUNT 2: SINGAPORE (SIN)            │
 │   • VCN: 10.100.0.0/16                  │      │   • VCN: 10.200.0.0/16                  │
 │   • ADB 23ai Vector DB: finsightsvec1   │      │   • ADB 23ai Vector DB: finsightsvec2   │
 │   • Object Storage: finsights-tokyo     │      │   • Object Storage: finsights-singapore │
 │   • MySQL DB System: finsights-tokyo    │      │   • MySQL DB System: finsights-singapore│
 └─────────────────────────────────────────┘      └─────────────────────────────────────────┘
```

---

## 2. Resource Specifications & Free Tier Quotas

| Component | Account 1 (Tokyo) | Account 2 (Singapore) | Free Tier Benefit | Purpose |
|---|---|---|---|---|
| **AI Vector DB** | ADB 23ai (`finsightsvec1`) | ADB 23ai (`finsightsvec2`) | **2x (2 ECPUs, 20 GB)** Always Free | Vector embeddings, RAG, AI Agent |
| **Object Storage** | `finsights-data-assets-tokyo` | `finsights-data-assets-singapore` | **2x (10 GB Standard)** Always Free | PDF reports, media, cross-region backups |
| **Relational DB** | MySQL DB System (Tokyo) | MySQL DB System (Singapore) | Managed PaaS in Private Subnet | Structured tables, relations, HeatWave OLAP |
| **Networking** | VCN `10.100.0.0/16` | VCN `10.200.0.0/16` | Free included | Secure private network isolation |

---

## 3. Repository Structure

```text
finsights-oracle-database/
├── .github/
│   └── workflows/
│       └── deploy.yml              # CI/CD: Automated Terraform Plan & Apply for both accounts
├── .gitignore                      # Git ignore for state, wallets, and credentials
├── README.md                       # Architecture & quickstart documentation
├── terraform/
│   ├── versions.tf                 # Terraform >= 1.7.0 & OCI provider constraints
│   ├── provider.tf                 # Dual OCI provider configuration (account1 & account2)
│   ├── main.tf                     # Root composition with mirrored stacks
│   ├── variables.tf                # Input variables for both accounts
│   ├── terraform.tfvars.example    # Configuration template
│   ├── outputs.tf                  # Database endpoints, wallet export, S3 URLs for both accounts
│   └── modules/
│       ├── network/                # VCN, private subnet, route table, security list
│       ├── autonomous_database/    # Oracle Database 23ai Always Free (Vector DB)
│       ├── object_storage/         # OCI Object Storage bucket
│       └── mysql_heatwave/         # MySQL DB System and HeatWave cluster
└── docs/
    ├── 01-architecture-overview.md       # Detailed technical architecture
    ├── 02-autonomous-database-vector.md  # 23ai AI Vector Search guide (SQL & LangChain)
    ├── 03-mysql-heatwave-guide.md        # MySQL HeatWave setup & performance
    ├── 04-object-storage-guide.md        # Object Storage S3 API & PAR integration
    └── 05-github-secrets-setup.md        # Step-by-step CI/CD secrets configuration
```

---

## 4. Deployment Workflow

### Option A: Automated CI/CD (GitHub Actions)
Add the secrets listed in [`docs/05-github-secrets-setup.md`](docs/05-github-secrets-setup.md) to your GitHub repository (**Settings > Secrets and variables > Actions**), then push to `main` or trigger via **Actions > Deploy Finsights Oracle Database Resources > Run workflow**.

### Option B: Local Execution via Terraform CLI
```bash
cd terraform

# 1. Copy variables template
cp terraform.tfvars.example terraform.tfvars

# 2. Edit terraform.tfvars with your credentials and passwords
nano terraform.tfvars

# 3. Initialize and deploy
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```
