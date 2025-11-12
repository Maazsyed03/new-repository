

output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint_ip" {
  description = "The public IP address of the GKE control plane"
  value       = google_container_cluster.primary.endpoint
}

output "node_pool_name" {
  description = "The name of the GKE node pool"
  value       = google_container_node_pool.my_node_group.name
}

# --- Networking Info ---
output "network_name" {
  description = "The name of the custom VPC network"
  value       = google_compute_network.custom_network.name
}

output "subnet_ip_range" {
  description = "The IP CIDR range assigned to the custom subnet"
  value       = google_compute_subnetwork.custom_subnet.ip_cidr_range
}

# --- Enabled Google APIs ---
output "enabled_apis" {
  description = "List of Google Cloud APIs enabled for this project"
  value = [
    google_project_service.container_api.service,
    google_project_service.compute_api.service,
    google_project_service.cloudresourcemanager_api.service,
    google_project_service.serviceusage_api.service,
    google_project_service.iam_api.service
  ]
}
