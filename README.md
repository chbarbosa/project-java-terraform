# Local Microservices Infrastructure with Terraform
This project automates the local development environment for a Java-based microservices architecture. It uses Terraform to provision all necessary infrastructure components inside Docker, ensuring that the environment is consistent across different machines and environments (dev, acc, etc.).

## Overview
The infrastructure consists of:

* PostgreSQL: Primary database.
* LocalStack: Simulating AWS Services (S3 for file storage and SQS for messaging).
* Docker Network: Isolated network for service-to-service communication.
* Environment Sync: Automatic generation of .env files for Spring Boot applications.

## Prerequisites
* WSL2 (Ubuntu recommended)
* Docker Desktop
* Terraform (>= 1.0)
* AWS CLI (for manual verification)