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

# A general-purpose client VM in the hub for testing purposes.
resource "google_compute_instance" "vm-hub-cli1" {
  project      = var.projects["hub_project"].project_id
  zone         = "${var.region}-${var.hub_cli1_vm.zone_suffix}"
  name         = "vm-hub-cli1"
  machine_type = var.hub_vm_machine_type
  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }
  network_interface {
    network    = module.vpcs["hub"].network_self_link
    subnetwork = module.vpcs["hub"].subnets["${var.region}/${var.hub_subnet_name}"].self_link
    network_ip = var.hub_cli1_vm.ip_address
  }
  shielded_instance_config {
    enable_secure_boot = var.enable_secure_boot
  }
  metadata_startup_script = "#!/bin/bash\n echo 'Hub Base VM created!'"
  params {
    resource_manager_tags = {
      (google_tags_tag_key.security_role_tag_key.id) = google_tags_tag_value.ssh_via_iap_tag_value.id
    }
  }
}

# A simple web server VM in the hub for testing purposes.
resource "google_compute_instance" "vm-hub-www1" {
  project      = var.projects["hub_project"].project_id
  zone         = "${var.region}-${var.hub_www1_vm.zone_suffix}"
  name         = "vm-hub-www1"
  machine_type = var.hub_vm_machine_type
  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }
  network_interface {
    network    = module.vpcs["hub"].network_self_link
    subnetwork = module.vpcs["hub"].subnets["${var.region}/${var.hub_subnet_name}"].self_link
    network_ip = var.hub_www1_vm.ip_address
  }
  shielded_instance_config {
    enable_secure_boot = var.enable_secure_boot
  }
  metadata_startup_script = "#!/bin/bash\n sudo apt-get update && sudo apt-get install -y apache2 && echo 'Hello from Hub Web Server!' | sudo tee /var/www/html/index.html"
  params {
    resource_manager_tags = {
      (google_tags_tag_key.security_role_tag_key.id)    = google_tags_tag_value.ssh_via_iap_tag_value.id,
      (google_tags_tag_key.application_role_tag_key.id) = google_tags_tag_value.app_web_server_tag_value.id
    }
  }
}