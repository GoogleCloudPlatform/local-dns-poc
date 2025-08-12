# variables.tf

variable "gcs_bucket_name" {
  description = "The globally unique name for the GCS bucket for Terraform state."
  type        = string
}

variable "gcs_bucket_project_id" {
  description = "The ID of the project where the GCS bucket will be created."
  type        = string
}

variable "gcs_bucket_location" {
  description = "The location (region or multi-region) for the GCS bucket (e.g., 'US', 'europe-west1')."
  type        = string
  default     = "US-CENTRAL1"
}

variable "gcs_bucket_storage_class" {
  description = "The storage class for the GCS bucket (e.g., 'STANDARD', 'NEARLINE', 'COLDLINE', 'ARCHIVE')."
  type        = string
  default     = "STANDARD"
}