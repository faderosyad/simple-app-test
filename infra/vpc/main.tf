provider "google" {
  project = var.project_id
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "9.0"

  project_id   = var.project_id
  network_name = "${var.product_id}-vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name   = "${var.product_id}-subnet-${var.region}"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "${var.product_id}-subnet-${var.region}" = [
      {
        range_name    = "pod-range"
        ip_cidr_range = "192.168.0.0/16"
      },
      {
        range_name    = "service-range"
        ip_cidr_range = "192.167.0.0/24"
      },
    ]
  }
}

module "cloud-nat" {
  depends_on    = [module.vpc]
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "5.0"
  name          = "${var.product_id}-nat"
  project_id    = var.project_id
  region        = var.region
  network       = "${var.product_id}-vpc"
  create_router = true
  router        = "${var.product_id}-router"
}

resource "google_compute_address" "external_ip_address" {

  name         = "external-ip-address-istio-lb-api-${var.product_id}"
  region       = var.region
  network_tier = "PREMIUM"
}