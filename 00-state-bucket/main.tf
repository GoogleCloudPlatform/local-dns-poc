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