terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.30.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = var.project_id
  region = var.region
  credentials = file("${path.module}/gcp-key.json")
}