data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.1"

  project_id   = var.project_id
  network_name = "gkenodevpc"
  subnets      = [
    {
      subnet_name   = "public-subnet-1"
      subnet_ip     = "10.1.0.0/16"
      subnet_region = var.region
    },
    {
      subnet_name   = "private-subnet-1"
      subnet_ip     = "10.2.0.0/16"
      subnet_region = var.region
    }
  ]

  secondary_ranges = {
        private-subnet-1 = [
            {
                range_name    = "pods"
                ip_cidr_range = "10.10.0.0/16"
            },
            {
                range_name    = "services"
                ip_cidr_range = "10.12.0.0/16"
            },
        ]

        # subnet-02 = [
        #     {
        #         range_name    = "services"
        #         ip_cidr_range = "172.169.64.0/24"
        #     },
        # ]
    }
}

module "gke" {
  source       = "terraform-google-modules/kubernetes-engine/google"
  project_id   = var.project_id
  name         = var.cluster_name
  region       = var.region
  # zones        = ["us-central1-a", "us-central1-b", "us-central1-f"]
  network      = module.vpc.network_name
  subnetwork   = module.vpc.subnets_names[0]
  ip_range_pods = "pods"
  ip_range_services = "services"
  

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
      service_account           = "terraform-service-account@gcp-classes-395503.iam.gserviceaccount.com"
    }
  ]
}

module "sql" {
  source      = "./sql"
  project_id  = var.project_id
  region      = var.region
  network     = module.vpc.network_self_link
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
