# 🚀 AWS 3-Tier Web Application Architecture

A production-grade, highly available 3-tier web application infrastructure built on AWS and managed entirely with Terraform. This architecture demonstrates best practices for security, scalability, and reliability.

## 📋 Prerequisites

Before you begin, ensure you have the following:

1. **An AWS Account** with appropriate permissions to create resources.
2. **Terraform** (v1.0+) installed on your local machine. [Download here](https://www.terraform.io/downloads.html).
3. **AWS CLI** configured with your credentials (`aws configure`).
4. **An EC2 Key Pair** created in your target AWS region for SSH access.
5. **Git** installed to clone the repository.

## 🏗️ Architecture Overview

This project deploys a secure and scalable 3-tier architecture:

### **Tier 1: Presentation Layer (Public)**
- **Components:** Public Subnets, Internet Gateway, Application Load Balancer (ALB), CloudFront CDN.
- **Purpose:** Serves static content (React frontend) to users via a global CDN.

### **Tier 2: Application Layer (Private)**
- **Components:** Private Subnets, NAT Gateway, Internal ALB, Auto Scaling Group (EC2 Instances).
- **Purpose:** Hosts the backend application logic (Node.js API), isolated from the public internet.

### **Tier 3: Data Layer (Isolated)**
- **Components:** Database Subnets, Amazon RDS (MySQL).
- **Purpose:** Stores application data in a highly available, managed database.

## 📊 Architecture Diagram

Below is a visual overview of the deployed infrastructure:



**Flow Explanation:**

1. User requests the website via the CloudFront URL.
2. CloudFront serves cached static assets or forwards API requests to the External ALB.
3. External ALB routes traffic to Frontend Instances in private subnets.
4. Frontend Instances make API calls to the Internal ALB.
5. Internal ALB routes requests to Backend Instances.
6. Backend Instances query the RDS Database.
7. CloudWatch monitors all components and triggers SNS to send Email Alerts.

## 📁 Project Structure

```
terraform-aws-3tier/
├── providers.tf              # Terraform and AWS provider configuration
├── 01_networking.tf          # VPC, Subnets, IGW, NAT Gateway, Routing
├── 02_security.tf            # Security Groups & Policies
├── 03_database.tf            # RDS Instance, DB Subnet Group
├── 04_compute.tf             # Launch Templates, Auto Scaling Groups
├── 05_distribution.tf        # ALB, CloudFront, Caching Policies
├── 06_observability.tf       # CloudWatch Alarms, SNS Topics
├── outputs.tf                # Output values (URLs, endpoints)
├── variables.tf              # Input variable definitions
└── scripts/
    ├── frontend-userdata.sh  # Frontend instance bootstrap script
    └── backend-userdata.sh   # Backend instance bootstrap script
```

## ⚙️ Configuration

### 1. Clone the Repository
```bash
git clone https://github.com/M-Yassir/AWS-Projects/3_tier_web_app.git
```

### 2. Review Core Configuration Files

- **01_networking.tf**: Defines the VPC, subnets, and networking infrastructure.
- **02_security.tf**: Sets up security groups with least privilege access control.
- **03_database.tf**: Configures the Multi-AZ RDS MySQL instance for high availability.
- **04_compute.tf**: Defines Auto Scaling Groups for frontend and backend tiers.
- **05_distribution.tf**: Creates ALBs and CloudFront distribution for content delivery.
- **06_observability.tf**: Implements monitoring and alerting via CloudWatch and SNS.

## 🚀 Deployment

### Initial Deployment

Initialize Terraform and deploy the infrastructure:

```bash
# Initialize Terraform and providers
terraform init

# Review the execution plan
terraform plan

# Apply the configuration (will take 15-20 minutes)
# You will be prompted to enter the database password
terraform apply
```

When you run `terraform apply`, you will see a prompt like this:

```
var.db_password
  The password for the database master user

  Enter a value:
```

Enter your secure database password and press Enter. The deployment will then proceed.

### Access Your Application

After successful deployment, Terraform will output the URLs:

```bash
# Access your frontend via CloudFront
cloudfront_url = "https://d1234abcd.cloudfront.net"

# Output the public LB URL, just for testing that it is not accessible as it should be
external_alb_url = "http://backend-internal-alb-123456789.us-east-1.elb.amazonaws.com"
```

### Monitoring Setup

Check your email and confirm the SNS subscription to start receiving CloudWatch alerts for auto-scaling events and system health.

## 🛠️ Operations

### Connecting to Instances

SSH access to frontend instances is available but restricted by security groups. Backend instances are in private subnets and require access through a bastion host or SSM Session Manager.

### Scaling

The infrastructure is designed to scale automatically:

- **Horizontal Scaling**: Auto Scaling Groups add/remove instances based on CPU utilization.
- **Vertical Scaling**: Modify `instance_type` in launch templates and apply changes.

### Database Management

Connect to your RDS instance using the master credentials:

```bash
mysql -h <rds-endpoint> -u admin -p
```

## 🔧 Troubleshooting

### Common Issues

- **SNS Email Not Received**: Check spam folder and confirm subscription.
- **CloudFront 401 Errors**: Verify origin request policies are forwarding headers.
- **RDS Connection Failures**: Check security group rules and database credentials.

### Logs and Monitoring

- **CloudWatch Logs**: View system and application logs.
- **CloudWatch Metrics**: Monitor CPU utilization, request counts, and database connections.
- **SNS Notifications**: Receive alerts for operational events.

## 🧹 Cleanup

⚠️ **Warning**: This will destroy all resources and data.

```bash
# Review destruction plan
terraform plan -destroy

# Destroy all resources
terraform destroy -auto-approve
```

## 📊 Outputs

After successful deployment, Terraform will provide:

- `cloudfront_url` - The global endpoint for your web application
- `external_alb_url` - The external ALB endpoint for API requests

## 🛡️ Security Notes

- Frontend instances are in public subnets but only accept traffic from the External ALB security group.
- Backend instances are in private subnets with no public IP addresses.
- Database is only accessible from backend instances in the Backend security group.
- Security groups follow the principle of least privilege access control.

---

**Note**: This infrastructure will incur costs in your AWS account. Remember to run `terraform destroy` when you're finished to avoid ongoing charges.
