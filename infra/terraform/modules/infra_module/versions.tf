# versions.tf - Terraform version and provider requirements
# Ensures consistent provider versions and sets Docker provider for Windows

terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
  required_version = ">= 1.4.0"
}

# Configure Docker provider to use Windows named pipe
provider "docker" {
  host = "npipe:////./pipe/docker_engine"
}