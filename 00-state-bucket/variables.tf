/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may
 a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
  default     = "us-central1"
}

variable "gcs_bucket_storage_class" {
  description = "The storage class for the GCS bucket (e.g., 'STANDARD', 'NEARLINE', 'COLDLINE', 'ARCHIVE')."
  type        = string
  default     = "STANDARD"
}