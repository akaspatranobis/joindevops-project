variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  default     = "europe-west2"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  default     = "node-app-gke-cluster"
}

variable "db_name" {
  description = "The database name"
  default     = "mydb"
}

variable "db_user" {
  description = "The database user"
  default     = "admin"
}

variable "db_password" {
  description = "The database password"
  default     = "password"
}
