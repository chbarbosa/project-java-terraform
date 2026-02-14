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
    orders    = { port = 8080, db_name = "orders_db" }
    payments  = { port = 8081, db_name = "payments_db" }
    inventory = { port = 8082, db_name = "inventory_db" }
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
  
  healthcheck {
    test         = ["CMD-SHELL", "pg_isready -U postgres"]
    interval     = "5s"
    timeout      = "5s"
    retries      = 5
    start_period = "10s"
  }
}

resource "local_file" "envs_microsservicos" {
  for_each = local.microservicos

  filename = "${path.module}/.env.${each.key}"
  content  = <<-EOT
    # Server Config
    SERVER_PORT=${each.value.port}

    # Database
    DB_URL=jdbc:postgresql://localhost:${docker_container.db.ports[0].external}/app_db
    SPRING_DATASOURCE_PASSWORD=${var.db_password}

    # S3
    S3_ENDPOINT=http://localhost:4566
    S3_BUCKET_NAME=${aws_s3_bucket.uploads.bucket}

    # SQS
    ORDER_QUEUE_URL=${aws_sqs_queue.q_orders.url}
    
    # AWS Credentials
    AWS_ACCESS_KEY_ID=test
    AWS_SECRET_ACCESS_KEY=${var.aws_secret_key}
    
    # Internals
    INTERNAL_PAYMENTS_URL=http://localhost:8081
    INTERNAL_INVENTORY_URL=http://localhost:8082
    INTERNAL_LOCALSTACK_URL=http://localstack:4566
  EOT
}

# LocalStack
resource "docker_container" "localstack" {
  name  = "localstack-${terraform.workspace}"
  image = "localstack/localstack:latest"
  
  networks_advanced {
    name = docker_network.rede_app.name
    aliases = ["localstack"]
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
  depends_on = [docker_container.localstack]
}

resource "aws_sqs_queue" "q_orders" {
  name = "q-orders-${terraform.workspace}"
  depends_on = [docker_container.localstack]
  visibility_timeout_seconds = var.sqs_visibility_timeout
}

resource "docker_container" "apps" {
  # no java containers for lcl
  for_each = terraform.workspace == "dev" ? {} : local.microservicos

  name  = "ms-${each.key}-${terraform.workspace}"
  image = "alpine" # simple image
  command = ["tail", "-f", "/dev/null"] 
  
  networks_advanced {
    name = docker_network.rede_app.name
    aliases = ["ms-${each.key}"]
  }

  env = [
    "SERVER_PORT=${each.value.port}"
  ]
}
