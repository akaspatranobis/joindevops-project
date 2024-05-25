variable "region" {
  description = "The GCP region"
  
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "network" {
  description = "The network name to deploy resources into"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork name to deploy resources into"
  type        = string
}


variable "db_name" {
  description = "The database name"
  
}

variable "db_user" {
  description = "The database user"
  
}

variable "db_password" {
  description = "The database password"
  
}