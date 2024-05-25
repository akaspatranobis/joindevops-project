output "gke_cluster_name" {
  value = module.gke.name
}

output "network_self_link" {
  value = module.vpc.network_self_link
}

output "sql_instance_connection_name" {
  value = module.sql.connection_name
}

output "sql_instance_private_ip" {
  value = module.sql.private_ip
}
