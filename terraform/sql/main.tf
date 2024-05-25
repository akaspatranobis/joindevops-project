resource "google_sql_database_instance" "default" {
  name             = "my-sql-instance"
  database_version = "MYSQL_5_7"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network
      enable_private_path_for_google_cloud_services = true
    }
    

    backup_configuration {
      enabled = true
      start_time = "01:00"
    }
  }
}

resource "google_sql_database" "default" {
  name     = var.db_name
  instance = google_sql_database_instance.default.name
}

resource "google_sql_user" "default" {
  name     = var.db_user
  instance = google_sql_database_instance.default.name
  password = var.db_password
}

output "connection_name" {
  value = google_sql_database_instance.default.connection_name
}

output "private_ip" {
  value = google_sql_database_instance.default.private_ip_address
}
