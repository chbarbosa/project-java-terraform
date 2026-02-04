terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"}
  }
  backend "local" {
    path = "terraform.tfstate"
  }
}

locals {
  amb_ports = {
    default = 5432
    dev     = 5433
    acc     = 5434
    prod    = 5432
  }
  microservicos = {
    orders    = { port = 8081, db_name = "orders_db" }
    payments  = { port = 8082, db_name = "payments_db" }
    inventory = { port = 8083, db_name = "inventory_db" }
  }
}

provider "docker" {}

# 1. network
resource "docker_network" "rede_app" {
  name = "rede-microsservico-${terraform.workspace}"
}

# 2. postgres database
resource "docker_container" "db" {
  name  = "db-${terraform.workspace}"
  image = var.postgres_image
  networks_advanced {
    name = docker_network.rede_app.name
  }
  env = [
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=app_db"
  ]
  ports {
    internal = 5432
    external = lookup(local.amb_ports, terraform.workspace, 5435)
  }
}

# 3. .env file
resource "local_file" "env_file" {
  filename = "${path.module}/.env"
  content  = <<-EOT
    SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:${docker_container.db.ports[0].external}/app_db
    SPRING_DATASOURCE_USERNAME=postgres
    SPRING_DATASOURCE_PASSWORD=${var.db_password}
    
    # Configs
    AWS_S3_ENDPOINT=http://localhost:4566
    AWS_S3_BUCKET_NAME=${aws_s3_bucket.uploads.bucket}
    AWS_SQS_QUEUE_URL=${aws_sqs_queue.q_orders.url}
    AWS_REGION=us-east-1
    AWS_ACCESS_KEY=test
    AWS_SECRET_KEY=test
  EOT
}

# LocalStack
resource "docker_container" "localstack" {
  name  = "localstack-${terraform.workspace}"
  image = "localstack/localstack:latest"
  
  networks_advanced {
    name = docker_network.rede_app.name
  }

  ports {
    internal = 4566
    external = 4566
  }

  env = [
    "SERVICES=s3,sqs", # available services
    "DEFAULT_REGION=us-east-1"
  ]
}

# Provider da AWS withc LocalStack
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3  = "http://localhost:4566"
    sqs = "http://localhost:4566"
  }
}

# with LocalStack
resource "aws_s3_bucket" "uploads" {
  bucket = "my-app-uploads-${terraform.workspace}"
}

resource "aws_sqs_queue" "q_orders" {
  name = "q-orders-${terraform.workspace}"
  visibility_timeout_seconds = var.sqs_visibility_timeout
}

resource "docker_container" "apps" {
  for_each = local.microservicos 

  name  = "ms-${each.key}-${terraform.workspace}"
  image = "alpine" # simple image
  command = ["tail", "-f", "/dev/null"] 
  
  networks_advanced {
    name = docker_network.rede_app.name
  }

  ports {
    internal = 8080
    external = each.value.port
  }
}