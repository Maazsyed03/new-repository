# --- Project APIs (keep enabled on destroy) -------------------------------

resource "google_project_service" "container_api" {
  project            = var.project
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute_api" {
  project            = var.project
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudresourcemanager_api" {
  project            = var.project
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

# You generally don't need to manage this one via TF; but if you do,
# ensure it stays enabled on destroy.
resource "google_project_service" "serviceusage_api" {
  project            = var.project
  service            = "serviceusage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam_api" {
  project            = var.project
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

# --- Networking -----------------------------------------------------------

resource "google_compute_network" "custom_network" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom_subnet" {
  name          = "custom-subnetwork"
  ip_cidr_range = "10.10.0.0/16"
  region        = var.region
  network       = google_compute_network.custom_network.id
}

resource "google_compute_firewall" "allow_internal_v2" {
  name    = "internal-firewall-v2"
  network = google_compute_network.custom_network.id

  allow {
    protocol = "all"
  }

  source_ranges = ["10.10.0.0/16"]
}

resource "google_compute_firewall" "allow_external_v2" {
  name    = "external-firewall-v2"
  network = google_compute_network.custom_network.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_gke_v2" {
  name    = "gke-firewall-v2"
  network = google_compute_network.custom_network.id

  allow {
    protocol = "tcp"
    ports    = ["443", "10250", "15017"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# --- GKE ------------------------------------------------------------------

resource "google_container_cluster" "primary" {
  project                  = var.project
  name                     = "terraform-gke-cluster"
  location                 = var.zone       # zonal
  network                  = google_compute_network.custom_network.id
  subnetwork               = google_compute_subnetwork.custom_subnet.id
  deletion_protection      = false
  remove_default_node_pool = true
  initial_node_count       = 1

  # Ensure APIs are enabled before cluster creation.
  depends_on = [
    google_project_service.container_api,
    google_project_service.compute_api,
    google_project_service.cloudresourcemanager_api,
    google_project_service.iam_api,
    google_project_service.serviceusage_api,
  ]

  # Optional, but helps on slow deletes.
  timeouts {
    delete = "30m"
  }
}

resource "google_container_node_pool" "my_node_group" {
  name       = "my-node-pool"
  project    = google_container_cluster.primary.project
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  node_count = var.node_count

  node_config {
    image_type   = "ubuntu_containerd"
    disk_type    = "pd-standard"
    disk_size_gb = 10
    machine_type = "e2-standard-2"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  depends_on = [google_container_cluster.primary]

  timeouts {
    delete = "30m"
  }
}
