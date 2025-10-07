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

# Provision CLI VMs in Spoke PRD 
# vm-prd-cli1 - Use default DNS (Google)
# vm-prd-cli2 - Use custom DNS (local BIND servers in Hub)
resource "google_compute_instance" "spoke_prd_cli_vms" {
  for_each = var.spoke_prd_cli_vms

  project      = var.projects["spoke_prd_project"].project_id
  zone         = "${var.region}-${each.value.zone_suffix}"
  name         = each.key
  machine_type = var.spoke_prd_vm_machine_type

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    network    = module.vpcs["spoke_prd"].network_self_link
    subnetwork = module.vpcs["spoke_prd"].subnets["${var.region}/${var.spoke_prd_subnet_name}"].self_link
  }

  shielded_instance_config {
    enable_secure_boot = var.enable_secure_boot
  }

  metadata_startup_script = templatefile("${path.module}/scripts/configure-custom-dns.sh.tftpl", {
    target_hostname = keys(var.spoke_prd_cli_vms)[1]
    dns_server_ips = [
      for vm in var.dns_server_vms : vm.ip_address
    ]
  })

  params {
    resource_manager_tags = {
      (google_tags_tag_key.security_role_tag_key.id) = google_tags_tag_value.ssh_via_iap_tag_value.id
    }
  }
}

# Provision CLI VMs in Spoke DEV 
# vm-dev-cli1 - Use default DNS (Google)
# vm-dev-cli2 - Use custom DNS (local BIND servers in Hub)
resource "google_compute_instance" "spoke_dev_cli_vms" {
  for_each = var.spoke_dev_cli_vms

  project      = var.projects["spoke_dev_project"].project_id
  zone         = "${var.region}-${each.value.zone_suffix}"
  name         = each.key
  machine_type = var.spoke_dev_vm_machine_type

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    network    = module.vpcs["spoke_dev"].network_self_link
    subnetwork = module.vpcs["spoke_dev"].subnets["${var.region}/${var.spoke_dev_subnet_name}"].self_link
  }

  shielded_instance_config {
    enable_secure_boot = var.enable_secure_boot
  }

  metadata_startup_script = templatefile("${path.module}/scripts/configure-custom-dns.sh.tftpl", {
    target_hostname = keys(var.spoke_dev_cli_vms)[1]
    dns_server_ips = [
      for vm in var.dns_server_vms : vm.ip_address
    ]
  })

  params {
    resource_manager_tags = {
      (google_tags_tag_key.security_role_tag_key.id) = google_tags_tag_value.ssh_via_iap_tag_value.id
    }
  }
}