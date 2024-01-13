provider "google" {}

resource "google_project" "project" {
  name       = "fade-rosyad-project"
  project_id = "fade-rosyad-project"
  billing_account = "01C11D-57EB13-F01309"
}

module "project_services" {
  depends_on = [google_project.project]
  source     = "terraform-google-modules/project-factory/google//modules/project_services"
  version    = "14.4.0"

  project_id = google_project.project.project_id

  activate_apis = [
    "serviceusage.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "admin.googleapis.com",
    "servicenetworking.googleapis.com",
    "storage.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
  ]
}