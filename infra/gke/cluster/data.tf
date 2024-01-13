data "google_compute_network" "network" {
  name    = "${var.product_id}-vpc"
  project = var.project_id
}

data "google_compute_subnetwork" "subnetwork" {
  name    = "${var.product_id}-subnet-${var.region}"
  region  = var.region
  project = var.project_id
}