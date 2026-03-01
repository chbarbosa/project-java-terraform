# Local Microservices Infrastructure with Terraform
This project automates the local development environment for a Java-based microservices architecture. It uses Terraform to provision all necessary infrastructure components inside Docker, ensuring that the environment is consistent across different machines and environments (dev, acc, etc).

## Overview
The infrastructure consists of:

* PostgreSQL: Primary database.
* LocalStack: Simulating AWS Services (S3 for file storage and SQS for messaging).
* Prometheus: Real-time monitoring and observability for all services.
* Docker Network: Isolated network for service-to-service communication.
* Environment Sync: Automatic generation of .env files for Spring Boot applications.

## Prerequisites
* WSL2 (Ubuntu recommended)
* Docker Desktop
* Terraform (>= 1.0)
* AWS CLI (for manual verification)

## Quick start
1. Set Workspace: Select your environment (terraform workspace select acc).
2. Build: Run ./build.sh to create Docker images for the services.
3. Launch: Run ./start.sh to provision all infrastructure and containers.
4. Stop: Run ./clean.sh to tear down all resources.
Obs: dev workspace will not launch the services

### Monitoring Dashboard
Once the services are up, open http://localhost:9090 to access Prometheus.
* Use the Status -> Targets menu to verify if all microservices are UP.
* Search for process_uptime_seconds to track service stability.