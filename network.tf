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
  network_configs = {
    hub = {
      project_id   = var.projects["hub_project"].project_id
      network_name = var.hub_vpc_name
      subnets = [{
        subnet_name           = var.hub_subnet_name
        subnet_ip             = var.hub_subnet_ip
        subnet_region         = var.region
        subnet_private_access = "true"
      }]
    },
    spoke_prd = {
      project_id   = var.projects["spoke_prd_project"].project_id
      network_name = var.spoke_prd_vpc_name
      subnets = [{
        subnet_name           = var.spoke_prd_subnet_name
        subnet_ip             = var.spoke_prd_subnet_ip
        subnet_region         = var.region
        subnet_private_access = "true"
      }]
    },
    spoke_dev = {
      project_id   = var.projects["spoke_dev_project"].project_id
      network_name = var.spoke_dev_vpc_name
      subnets = [{
        subnet_name           = var.spoke_dev_subnet_name
        subnet_ip             = var.spoke_dev_subnet_ip
        subnet_region         = var.region
        subnet_private_access = "true"
      }]
    }
  }
}

# Create VPCs and subnets
module "vpcs" {
  source       = "terraform-google-modules/network/google"
  version      = "13.0.0"
  for_each     = local.network_configs
  project_id   = each.value.project_id
  network_name = each.value.network_name
  routing_mode = "GLOBAL"
  subnets      = each.value.subnets
  depends_on   = [google_project_service.apis] # Ensure APIs are enabled first
}

#Create VPC Peerings between Hub and Spokes
resource "google_compute_network_peering" "hub_to_spoke_prd" {
  name         = "hub-to-spoke-prd-peering"
  network      = module.vpcs["hub"].network_self_link
  peer_network = module.vpcs["spoke_prd"].network_self_link
}

resource "google_compute_network_peering" "spoke_prd_to_hub" {
  name         = "spoke-prd-to-hub-peering"
  network      = module.vpcs["spoke_prd"].network_self_link
  peer_network = module.vpcs["hub"].network_self_link
}

resource "google_compute_network_peering" "hub_to_spoke_dev" {
  name         = "hub-to-spoke-dev-peering"
  network      = module.vpcs["hub"].network_self_link
  peer_network = module.vpcs["spoke_dev"].network_self_link
}

resource "google_compute_network_peering" "spoke_dev_to_hub" {
  name         = "spoke-dev-to-hub-peering"
  network      = module.vpcs["spoke_dev"].network_self_link
  peer_network = module.vpcs["hub"].network_self_link
}

# Configure Cloud NAT for each VPC to allow outbound internet access for VMs without external IPs
locals {
  nat_configs = {
    "hub" = {
      project_id        = var.projects["hub_project"].project_id
      network_self_link = module.vpcs["hub"].network_self_link
    },
    "spoke-prd" = {
      project_id        = var.projects["spoke_prd_project"].project_id
      network_self_link = module.vpcs["spoke_prd"].network_self_link
    },
    "spoke-dev" = {
      project_id        = var.projects["spoke_dev_project"].project_id
      network_self_link = module.vpcs["spoke_dev"].network_self_link
    }
  }
}

resource "google_compute_router" "nat_router" {
  for_each = local.nat_configs
  name     = "${each.key}-nat-router-${var.region}"
  project  = each.value.project_id
  region   = var.region
  network  = each.value.network_self_link
}

resource "google_compute_router_nat" "nat_gateway" {
  for_each                           = google_compute_router.nat_router
  name                               = "${each.key}-nat-gateway-${var.region}"
  router                             = each.value.name
  region                             = each.value.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = each.value.project
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}