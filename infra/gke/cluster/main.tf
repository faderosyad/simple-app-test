# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate  = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.project_id
  name                       = "gke-${var.product_id}"
  region                     = "us-central1"
  zones                      = ["us-central1-b" , "us-central1-c"]
  network                    = data.google_compute_network.network.name
  subnetwork                 = data.google_compute_subnetwork.subnetwork.name
  ip_range_pods              = data.google_compute_subnetwork.subnetwork.secondary_ip_range[0].range_name
  ip_range_services          = data.google_compute_subnetwork.subnetwork.secondary_ip_range[1].range_name
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver        = false

  node_pools = [
    {
      name               = "${var.product_id}-node-pool"
      machine_type       = "e2-medium"
      node_locations     = "us-central1-b,us-central1-c"
      min_count          = 1
      max_count          = 2
      local_ssd_count    = 0
      spot               = true
      disk_size_gb       = 40
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = false
      enable_gvnic       = false
      logging_variant    = "DEFAULT"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false
      initial_node_count = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}
  }

  node_pools_metadata = {
    all = {
      managed_by = "terraform"
    }
  }

  node_pools_taints = {
    all = []
  }

  node_pools_tags = {
    all = ["kube"]
  }
}