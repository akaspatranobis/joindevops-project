
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.0"

  project_id   = var.project_id
  network_name = "gke-node-vpc"
  subnets      = [
    {
      subnet_name   = "public-subnet-1"
      subnet_ip     = "10.0.1.0/24"
      subnet_region = var.region
    },
    {
      subnet_name   = "private-subnet-1"
      subnet_ip     = "10.0.2.0/24"
      subnet_region = var.region
    }
  ]
}

module "gke" {
  source       = "terraform-google-modules/kubernetes-engine/google"
  project_id   = var.project_id
  name         = var.cluster_name
  region       = var.region
  network      = module.vpc.network_name
  subnetwork   = module.vpc.subnets_names[0]
  ip_range_pods = "10.4.0.0/14"
  ip_range_services = "10.8.0.0/20"

  node_pools = [
    {
      name          = "default-node-pool"
      machine_type  = "e2-medium"
      min_count     = 1
      max_count     = 3
      disk_size_gb  = 20
      preemptible   = false
      auto_repair   = true
      auto_upgrade  = true
      initial_node_count = 1
    }
  ]
}

module "sql" {
  source      = "./sql"
  project_id  = var.project_id
  region      = var.region
  network     = module.vpc.network_name
  subnetwork  = module.vpc.subnets_names[1]
  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password
}

module "firewall" {
  source         = "./firewall"
  project_id     = var.project_id
  network        = module.vpc.network_name
  gke_master_ip  = module.gke.endpoint
  sql_instance_ip = module.sql.private_ip
}
