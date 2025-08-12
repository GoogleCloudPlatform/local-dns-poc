resource "google_storage_bucket" "terraform_state_bucket" {
  name          = var.gcs_bucket_name
  project       = var.gcs_bucket_project_id
  location      = var.gcs_bucket_location
  storage_class = var.gcs_bucket_storage_class
  force_destroy = true
  uniform_bucket_level_access = true # Recommended for security
  versioning {
    enabled = true # Recommended to keep a history of your state files
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 5 # Keep 5 previous versions, adjust as needed
    }
  }
}