# Automated CI/CD Pipeline for Docker Containers 🚀

## Introduction
Welcome to the Automated CI/CD Pipeline repository! This project demonstrates the development of a fully automated continuous integration and deployment system for Docker containers using Amazon Web Services (AWS). The pipeline streamlines building, testing, and deploying applications, ensuring efficient and reliable delivery while operating within AWS Free Tier constraints.

The project is highly beneficial for organizations adopting DevOps practices, as it reduces manual intervention, minimizes deployment errors, and accelerates feature delivery. By leveraging AWS CodePipeline, CodeBuild, ECR, ECS, and ALB, it provides a seamless, scalable deployment process that enhances operational efficiency and application reliability.

## Key Features

### ✅ Automated CI/CD Pipeline
- Integrated with GitHub for automatic change detection
- CodeBuild compiles code and creates Docker images
- CodeDeploy updates ECS services with zero downtime

### ✅ Docker Image Management
- Automated builds using Dockerfiles
- Version-controlled storage in Amazon ECR
- Secure image distribution to ECS clusters

### ✅ Scalable Deployment
- Container orchestration with Amazon ECS
- Supports both EC2 and Fargate launch types
- Automatic scaling based on demand

### ✅ Reliable Traffic Routing
- Application Load Balancer distributes traffic
- Health checks ensure only healthy containers receive requests
- Seamless deployment transitions

## AWS Services Used

**AWS CodePipeline**  
Orchestrates the complete CI/CD workflow from source to deployment

**AWS CodeBuild**  
Builds Docker images from source code and pushes to ECR

**Amazon ECR**  
Secure Docker container registry with image scanning

**Amazon ECS**  
Managed container orchestration service

**Application Load Balancer**  
Distributes traffic across containers with health checks

## Application Workflow

1. **Code Push**: Developers commit changes to GitHub repository
2. **Pipeline Trigger**: CodePipeline detects changes automatically
3. **Build Phase**:
   - CodeBuild pulls latest code
   - Creates Docker image using Dockerfile
   - Pushes image to ECR with version tag
4. **Deploy Phase**:
   - ECS pulls new image from ECR
   - Updates service with rolling deployment
   - ALB routes traffic to new containers
5. **Monitoring**:
   - CloudWatch tracks performance metrics
   - Logs stored for debugging

## Video Demonstration 📹
https://github.com/user-attachments/assets/0812eb74-891e-4603-b963-9178df148bc7

## Important Note 🚨
This project was developed as a learning exercise within AWS Free Tier limits. The live implementation has been terminated, but the code and documentation remain available for educational purposes.

## Getting Started
Clone the Repository: git clone https://github.com/M-Yassir/AWS-Projects.git

Navigate to the Project Directory: cd Container_deployment_with_CICD

Open the weather-app application in your editor

Make sure that you have the latest version of the AWS CLI and Docker installed.                                 

Follow the Documentation: Check out the detailed docs to set up the app.

## Contributing
We welcome contributions! If you have any suggestions or improvements, feel free to submit issues or pull requests.
