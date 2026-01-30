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
}

locals {
  amb_ports = {
    default = 5432
    dev     = 5433
    acc     = 5434
    prod    = 5432
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
  image = "postgres:15-alpine"
  networks_advanced {
    name = docker_network.rede_app.name
  }
  env = [
    "POSTGRES_PASSWORD=password123",
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
    SPRING_DATASOURCE_PASSWORD=password123
  EOT
}