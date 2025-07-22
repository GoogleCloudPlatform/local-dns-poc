/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


# Local variables to create a map from the input lists.
# This makes it easier to iterate over the projects and their associated network configurations.
locals {
  projects_data = {
    "${var.project_id_hub}" = {
      vpc_name = var.vpc_name_hub
      subnet   = var.subnet_hub
    },
    "${var.project_id_prd}" = {
      vpc_name = var.vpc_name_prd
      subnet   = var.subnet_prd
    },
    "${var.project_id_dev}" = {
      vpc_name = var.vpc_name_dev
      subnet   = var.subnet_dev
    }
  }
}

# This module creates a VPC and a subnet in each project defined above.
# It iterates over the same map, ensuring that each network is created in the corresponding project.
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  for_each = local.projects_data

  # The project_id is taken from the key of the for_each map, as projects are expected to exist.
  project_id   = each.key
  network_name = each.value.vpc_name

  # Defines the subnet to be created within the VPC.
  # The subnet definition conforms to the specified object structure.
  subnets = [
    each.value.subnet
  ]
}

