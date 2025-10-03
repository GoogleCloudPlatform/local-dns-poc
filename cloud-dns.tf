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
  spoke_configs = {
    "prd" = {
      project_id    = var.projects["spoke_prd_project"].project_id
      vpc_self_link = module.vpcs["spoke_prd"].network_self_link
    },
    "dev" = {
      project_id    = var.projects["spoke_dev_project"].project_id
      vpc_self_link = module.vpcs["spoke_dev"].network_self_link
    },
  }
}

# This resource introduces a fixed delay after the DNS server VMs are created.
resource "time_sleep" "wait_for_vm_startup" {
  create_duration = "50s"
  depends_on      = [google_compute_instance.hub_dns_server_vms]
}

# "Catch-all" forwarding zone for the root domain (.).
# This forwards all non-matching queries to the central BIND servers.
resource "google_dns_managed_zone" "hub_root_forwarding_zone" {
  project     = var.projects["hub_project"].project_id
  name        = "hub-root-forwarding-zone"
  dns_name    = "."
  description = "Hub forwarding zone for the root domain to central BIND servers."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = module.vpcs["hub"].network_self_link
    }
  }

  forwarding_config {
    dynamic "target_name_servers" {
      for_each = google_compute_instance.hub_dns_server_vms
      content {
        ipv4_address = target_name_servers.value.network_interface[0].network_ip
      }
    }
  }

  # This explicit dependency ensures that this zone is only created after the 50-second
  # delay, allowing time for the DNS server VMs to complete the BIND installation using
  # initially the Cloud DNS default resolution.
  depends_on = [time_sleep.wait_for_vm_startup]
}

# Peering for the root (.) forwarding zone.
# This allows the spokes to use the hub's "catch-all" rule.
resource "google_dns_managed_zone" "spoke_root_peering_zone" {
  for_each = local.spoke_configs

  project     = each.value.project_id
  name        = "spoke-root-peering-zone-${each.key}"
  dns_name    = "."
  description = "Spoke ${each.key} peering to Hub's root forwarding zone."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = each.value.vpc_self_link
    }
  }

  peering_config {
    target_network {
      network_url = module.vpcs["hub"].network_self_link
    }
  }
}