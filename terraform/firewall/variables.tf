variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "network" {
  description = "The name of the network to attach this firewall rule to."
  type        = string
}
