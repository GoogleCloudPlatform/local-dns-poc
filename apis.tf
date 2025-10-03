/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  # This local creates a flat map of {project_id}-{api_name} => {project_id, service_name},
  # which is necessary for iterating with for_each in the google_project_service resource.
  project_api_pairs = tomap({
    for pair in flatten([
      for proj_key, proj_details in var.projects : [
        for api in proj_details.apis : {
          key        = "${proj_key}-${api}"
          project_id = proj_details.project_id
          service    = api
        }
      ]
    ]) : pair.key => pair
  })
}

# Enable required APIs for each project
resource "google_project_service" "apis" {
  for_each = local.project_api_pairs

  project                    = each.value.project_id
  service                    = each.value.service
  disable_on_destroy         = false
  disable_dependent_services = true
}