resource "google_compute_firewall" "gke_to_sql" {
  name    = "allow-gke-to-sql"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges = ["10.0.0.0/8"]
  target_tags   = ["gke-node"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

variable "network" {
  description = "The name of the VPC network"
  type        = string
}

variable "gke_master_ip" {
  description = "The IP address of the GKE master"
  type        = string
}

variable "sql_instance_ip" {
  description = "The private IP address of the Cloud SQL instance"
  type        = string
}
