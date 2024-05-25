output "gke_cluster_name" {
  value = module.gke.name
}

output "gke_cluster_endpoint" {
  value = module.gke.endpoint
}

output "gke_cluster_ca_certificate" {
  value = module.gke.ca_certificate
}

output "sql_instance_connection_name" {
  value = module.sql.connection_name
}

output "sql_instance_private_ip" {
  value = module.sql.private_ip
}
