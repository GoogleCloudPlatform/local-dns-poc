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
  # --- Records for the domain zone ---
  acme_ns_records = join("\n", [
    for name, details in var.dns_server_vms : "@       IN      NS      ${name}"
  ])
  acme_a_records = join("\n", [
    for name, details in var.dns_server_vms : "${name}    IN      A       ${details.ip_address}"
  ])

  # --- Records for the googleapis.com zone ---
  googleapis_ns_records = join("\n", [
    for name, details in var.dns_server_vms : "@       IN      NS      ${name}"
  ])

  # These are the "glue" records needed so the nameservers can be resolved.
  googleapis_a_records = join("\n", [
    for name, details in var.dns_server_vms : "${name}    IN      A       ${details.ip_address}"
  ])

  # --- A records for other VMs in the environment ---
  # This local consolidates A records for various client and utility VMs.
  other_a_records = join("\n", concat(
    [for name, details in var.spoke_prd_cli_vms : "${name}    IN      A       ${details.ip_address}"],
    [for name, details in var.spoke_dev_cli_vms : "${name}    IN      A       ${details.ip_address}"],
    [
      # A records for hub utility VMs
      "vm-hub-cli1    IN      A       ${var.hub_cli1_vm.ip_address}",
      "vm-hub-www1    IN      A       ${var.hub_www1_vm.ip_address}",
      # Additional alias for the web server
      "www            IN      A       ${var.hub_www1_vm.ip_address}"
    ]
  ))
}

resource "google_compute_instance" "hub_dns_server_vms" {
  for_each     = var.dns_server_vms
  project      = var.projects["hub_project"].project_id
  zone         = "${var.region}-${each.value.zone_suffix}"
  name         = each.key
  machine_type = var.hub_vm_machine_type
  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }
  network_interface {
    network    = module.vpcs["hub"].network_self_link
    subnetwork = module.vpcs["hub"].subnets["${var.region}/${var.hub_subnet_name}"].self_link
    network_ip = each.value.ip_address
  }
  shielded_instance_config {
    enable_secure_boot = var.enable_secure_boot
  }

  metadata = {
    startup-script = templatefile("${path.module}/scripts/configure-bind-server.sh.tftpl", {
      domain_name           = var.domain_name
      acme_ns_records       = local.acme_ns_records
      acme_a_records        = local.acme_a_records
      googleapis_ns_records = local.googleapis_ns_records
      googleapis_a_records  = local.googleapis_a_records
      other_a_records       = local.other_a_records
    })
  }

  params {
    resource_manager_tags = {
      (google_tags_tag_key.security_role_tag_key.id) = google_tags_tag_value.ssh_via_iap_tag_value.id
    }
  }
}