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
  # --- Records for the acme.local zone ---
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
    startup-script = <<-EOF
      #! /bin/bash
      set -euo pipefail

      # --- Idempotency Check ---
      # If the main BIND zone file exists, assume configuration is complete and exit.
      if [ -f /etc/bind/db.fwd.${var.domain_name} ]; then
        echo "BIND zone file /etc/bind/db.fwd.${var.domain_name} already exists. Exiting."
        exit 0
      fi

      # --- BIND9 Configuration ---
      # 1. System updates and package installation
      echo "Updating and installing packages..."
      sudo apt-get update
      sudo apt-get install -y bind9 bind9utils bind9-doc

      # 2. Configure BIND9 global options for recursion
      echo "Configuring BIND9 global options..."
      sudo tee /etc/bind/named.conf.options > /dev/null <<EOT
      options {
        directory "/var/cache/bind";
        forwarders { 8.8.8.8; 8.8.4.4; };
        forward only;
        allow-query { any; };
        recursion yes;
        dnssec-validation auto;
        listen-on-v6 { any; };
      };
      EOT

      # 3. Create the authoritative zone file for the customer domain
      echo "Creating authoritative zone file for ${var.domain_name}..."
      sudo tee /etc/bind/db.fwd.${var.domain_name} > /dev/null <<EOT
      ; BIND data file for ${var.domain_name}
      \$TTL    604800
      @       IN      SOA     ${var.domain_name}. admin.${var.domain_name}. ( 3 604800 86400 2419200 604800 )
      
      ; Name Server records for ${var.domain_name}
      ${local.acme_ns_records}

      ; Glue records for ${var.domain_name} nameservers
      ${local.acme_a_records}

      ; Other records for the zone
      www1    IN      A       10.0.0.21
      EOT

      # 4. Create the new authoritative zone file for googleapis.com
      echo "Creating authoritative zone file for googleapis.com..."
      sudo tee /etc/bind/db.googleapis.com > /dev/null <<EOT
      ; BIND data file for googleapis.com
      \$TTL    300
      @       IN      SOA     googleapis.com. admin.googleapis.com. ( 1 3600 600 86400 300 )

      ; Name Server records for googleapis.com
      ${local.googleapis_ns_records}

      ; Glue records for googleapis.com nameservers
      ${local.googleapis_a_records}
      
      ; A records for restricted and private access
      restricted  IN  A   199.36.153.4
      restricted  IN  A   199.36.153.5
      restricted  IN  A   199.36.153.6
      restricted  IN  A   199.36.153.7
      private     IN  A   199.36.153.8
      private     IN  A   199.36.153.9
      private     IN  A   199.36.153.10
      private     IN  A   199.36.153.11
      
      ; Wildcard CNAME that points all other subdomains to private.googleapis.com
      *           IN  CNAME   private.googleapis.com.
      EOT

      # 5. Configure local zones
      echo "Configuring local BIND zones..."
      sudo tee /etc/bind/named.conf.local > /dev/null <<EOT
      // Authoritative Zone for ${var.domain_name}
      zone "${var.domain_name}" IN {
        type master;
        file "/etc/bind/db.fwd.${var.domain_name}";
      };

      // Authoritative Zone for googleapis.com
      zone "googleapis.com" IN {
        type master;
        file "/etc/bind/db.googleapis.com";
      };
      EOT

      # 6. Restart BIND9 to apply all changes
      echo "Restarting BIND9 service..."
      sudo systemctl restart named.service
      
      echo "BIND9 configuration complete."
      
    EOF
  }

  params {
    resource_manager_tags = {
      (google_tags_tag_key.security_role_tag_key.id) = google_tags_tag_value.ssh_via_iap_tag_value.id
    }
  }
}