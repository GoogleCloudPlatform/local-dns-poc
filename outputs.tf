/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "hub_dns_server_ips" {
  description = "Details of the hub DNS server VMs, including IP, project, and zone."
  value = { for name, instance in google_compute_instance.hub_dns_server_vms : name => {
    ip_address = instance.network_interface[0].network_ip
    project    = instance.project
    zone       = instance.zone
  } }
}

output "hub_utility_vm_ips" {
  description = "Details of the hub utility VMs, including IP, project, and zone."
  value = {
    (google_compute_instance.vm-hub-cli1.name) = {
      ip_address = google_compute_instance.vm-hub-cli1.network_interface[0].network_ip,
      project    = google_compute_instance.vm-hub-cli1.project,
      zone       = google_compute_instance.vm-hub-cli1.zone
    },
    (google_compute_instance.vm-hub-www1.name) = {
      ip_address = google_compute_instance.vm-hub-www1.network_interface[0].network_ip,
      project    = google_compute_instance.vm-hub-www1.project,
      zone       = google_compute_instance.vm-hub-www1.zone
    }
  }
}

output "spoke_prd_cli_vm_ips" {
  description = "Details of the spoke production client VMs, including IP, project, and zone."
  value = { for name, instance in google_compute_instance.spoke_prd_cli_vms : name => {
    ip_address = instance.network_interface[0].network_ip
    project    = instance.project
    zone       = instance.zone
  } }
}

output "spoke_dev_cli_vm_ips" {
  description = "Details of the spoke development client VMs, including IP, project, and zone."
  value = { for name, instance in google_compute_instance.spoke_dev_cli_vms : name => {
    ip_address = instance.network_interface[0].network_ip
    project    = instance.project
    zone       = instance.zone
  } }
}