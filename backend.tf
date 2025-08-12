# main_directory/backend.tf
terraform {
  backend "gcs" {
    bucket = "gsleiman-seed-project-bucket"
    prefix = "terraform/state"
  }
}