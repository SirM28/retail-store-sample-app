# 🏬 Project Bedrock — Retail Store Microservices on AWS EKS

This project is part of the **AltSchool of Engineering Tinyuka Semester (Cloud Engineering Track)**.  
It demonstrates full **Infrastructure as Code (IaC)** provisioning, **containerized microservices**, and a complete **CI/CD pipeline** for deploying workloads to **Amazon EKS**.

---

## 🧱 Project Overview

The **Retail Store Sample App** is a microservices-based retail platform designed to simulate a production-grade cloud environment.  
It uses **Terraform** for infrastructure provisioning, **Docker** for containerization, and **GitHub Actions** for automated deployments.

### 🧩 Microservices
Each service runs as a separate containerized app deployed to EKS:
- `orders-service` — manages order creation and retrieval  
- `catalog-service` — manages product data (via MySQL RDS)  
- `cart-service` — manages customer shopping carts (via DynamoDB)

---

## ☁️ Cloud Architecture

| Component | Description |
|------------|-------------|
| **Amazon EKS** | Hosts all retail microservices in Kubernetes pods |
| **VPC, Subnets, Gateways** | Provisioned via Terraform |
| **Amazon RDS (MySQL)** | Product catalog storage |
| **Amazon DynamoDB** | Cart data storage |
| **IAM Roles/Policies** | Granular roles for Terraform, EKS, and developer access |
| **LoadBalancer Service** | Exposes microservices to the internet |
| **S3 Backend** | Stores Terraform state files remotely |
| **GitHub OIDC Role** | Enables GitHub Actions to deploy securely without static AWS keys |

---

## 🏗️ Infrastructure as Code (IaC)

Infrastructure is fully managed via **Terraform** and modularized for maintainability.

### 🗂️ Terraform Directory Structure
```
terraform/
│
├── main.tf                # Root configuration and provider setup
├── vpc.tf                 # Networking (VPC, subnets, route tables)
├── eks.tf                 # EKS cluster, node groups, IAM roles
├── rds.tf                 # RDS MySQL instance
├── dynamodb.tf            # DynamoDB table for cart service
├── iam-developer-readonly.tf  # IAM read-only developer user
├── github_oidc_role.tf    # GitHub Actions OIDC integration
└── outputs.tf             # Exposed infrastructure outputs
```

### 🪄 Key Terraform Outputs
| Output | Description |
|---------|-------------|
| `cluster_name` | EKS cluster name |
| `cluster_endpoint` | API server endpoint |
| `rds_mysql_endpoint` | MySQL connection string |
| `dynamodb_table_name` | DynamoDB table name |
| `kubeconfig_aws_auth_command` | Command to configure kubectl |
| `developer_readonly_user` | IAM user for developer access |

---

## 🔐 IAM & Security

### 1. **GitHub Actions OIDC Role**
Allows GitHub workflows to assume an IAM role (`bedrock-terraform-role`) using OIDC authentication — no static credentials required.

### 2. **Read-Only Developer IAM User**
Created for observation-only access with permissions to:
- `eks:List*`, `eks:Describe*`
- `cloudwatch:Get*`, `logs:Get*`
- `rds:Describe*`
- `dynamodb:List*`, `dynamodb:Query*`
- `s3:List*`, `s3:Get*`

---

## 🔄 CI/CD — Automated Terraform Deployment

GitHub Actions pipeline: `.github/workflows/terraform-deploy.yml`

### 🔧 Workflow Overview
| Step | Description |
|------|-------------|
| **Checkout** | Fetches repository code |
| **Configure AWS Credentials** | Assumes OIDC role into AWS |
| **Setup Terraform** | Installs and configures Terraform |
| **Terraform Init** | Initializes remote backend |
| **Terraform Validate** | Validates syntax |
| **Terraform Plan** | Creates infrastructure plan |
| **Terraform Apply (main branch only)** | Applies changes automatically |

---

## 🚀 Deploying the Application

### 1. **Build and Push Docker Images**
```bash
docker build -t retail/orders:latest src/orders
docker push retail/orders:latest
```

### 2. **Apply Kubernetes Configs**
```bash
kubectl apply -f k8s/orders-config.yaml
kubectl apply -f k8s/orders-deployment.yaml
kubectl apply -f k8s/orders-service.yaml
```

### 3. **Verify Service**
```bash
kubectl get svc -n retail
curl http://<LOADBALANCER-DNS>/actuator/health
```

Expected response:
```json
{"status":"UP"}
```

---

## 🧠 Verification & Testing

| Test | Command | Expected Result |
|------|----------|----------------|
| Check EKS clusters | `aws eks list-clusters --profile readonly` | Shows `bedrock-retail-eks` |
| List DynamoDB tables | `aws dynamodb list-tables --profile readonly` | Lists `retail-carts` |
| Verify read-only user | `aws sts get-caller-identity --profile readonly` | Returns IAM user ARN |
| Access health check | `curl <LB-DNS>/actuator/health` | Returns status `UP` |

---

## 📁 Repository Structure

```
.
├── src/
│   ├── orders/
│   │   ├── Dockerfile
│   │   ├── pom.xml
│   │   └── src/main/java/com/amazon/sample/orders
│   ├── catalog/
│   └── cart/
├── k8s/
│   ├── orders-config.yaml
│   ├── orders-deployment.yaml
│   └── orders-service.yaml
├── terraform/
│   └── (Terraform IaC)
└── .github/workflows/
    └── terraform-deploy.yml
```

---

## 🧭 Architecture Diagram

```mermaid
graph TD

subgraph GitHub["GitHub Actions CI/CD"]
    A1[Checkout Code] --> A2[Configure AWS Credentials via OIDC]
    A2 --> A3[Terraform Init/Plan/Apply]
end

subgraph AWS["AWS Cloud (us-east-1)"]
    A3 --> B1[VPC (Public + Private Subnets)]
    B1 --> B2[EKS Cluster]
    B2 -->|Deploys| B3[Orders Service Pod]
    B2 -->|Deploys| B4[Catalog Service Pod]
    B2 -->|Deploys| B5[Cart Service Pod]
    B3 -->|External Access| B6[LoadBalancer Service]
    B4 -->|Connects| B7[RDS MySQL Database]
    B5 -->|Connects| B8[DynamoDB Table]
    B2 -->|Monitoring| B9[CloudWatch Logs]
end

subgraph IAM["AWS IAM"]
    C1[OIDC Provider: token.actions.githubusercontent.com]
    C2[Role: bedrock-terraform-role]
    C3[User: developer-readonly]
    C1 --> C2
    C2 --> A2
end

C3 -.->|CLI Access| AWS
B9 -->|Metrics| GitHub
```

---

## 🧰 Tools & Technologies

| Category | Tool |
|-----------|------|
| **Infrastructure** | Terraform, AWS, EKS |
| **CI/CD** | GitHub Actions |
| **Containerization** | Docker |
| **Orchestration** | Kubernetes |
| **Database** | RDS (MySQL), DynamoDB |
| **Monitoring** | AWS CloudWatch, Spring Actuator |
| **Programming** | Java 21 (Spring Boot 3.5.5) |

---

## 🧩 Maintainer
**Name:** Mayowa Oladunni  
**Role:** Cloud Engineering Student — AltSchool Africa  
**Project:** Tinyuka Second Semester Cloud Engineering Project  
**GitHub:** [@SirM28](https://github.com/SirM28)

---

## ✅ Evaluation Summary

| Rubric Criteria | Evidence |
|------------------|-----------|
| **EKS + VPC via IaC** | Terraform-provisioned resources verified via outputs |
| **IAM Roles (Least Privilege)** | Custom IAM role & policy in Terraform |
| **Automated CI/CD via GitHub Actions** | `terraform-deploy.yml` with OIDC |
| **Microservices Deployment** | Orders service deployed to EKS with LoadBalancer |
| **In-cluster Dependencies** | ConfigMaps & internal networking configured |
| **Read-only IAM User** | Verified through AWS CLI |
| **Organized Repository + README** | Clean structure and detailed documentation |

---

## 🏁 Final Note

This project demonstrates a **complete cloud-native deployment pipeline** —  
from infrastructure provisioning to microservice orchestration —  
fully automated, secure, and production-ready using AWS, Terraform, and GitHub Actions.
