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
# Add this provider block to your main.tf, likely near the top

# --------------------
# 01-gcp-api-enablement
# --------------------
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

resource "google_project_service" "apis" {
  for_each = local.project_api_pairs

  project                    = each.value.project_id
  service                    = each.value.service
  disable_on_destroy         = false
  disable_dependent_services = true
}


# --------------------
# 02-vpc-networks
# --------------------
locals {
  network_configs = {
    hub = {
      project_id   = var.projects["hub_project"].project_id
      network_name = var.hub_vpc_name
      subnets = [{
        subnet_name   = var.hub_subnet_name
        subnet_ip     = var.hub_subnet_ip
        subnet_region = var.region
      }]
    },
    spoke_prd = {
      project_id   = var.projects["spoke_prd_project"].project_id
      network_name = var.spoke_prd_vpc_name
      subnets = [{
        subnet_name   = var.spoke_prd_subnet_name
        subnet_ip     = var.spoke_prd_subnet_ip
        subnet_region = var.region
      }]
    },
    spoke_dev = {
      project_id   = var.projects["spoke_dev_project"].project_id
      network_name = var.spoke_dev_vpc_name
      subnets = [{
        subnet_name   = var.spoke_dev_subnet_name
        subnet_ip     = var.spoke_dev_subnet_ip
        subnet_region = var.region
      }]
    }
  }
}

module "vpcs" {
  source     = "terraform-google-modules/network/google"
  version    = "11.1.1"
  for_each   = local.network_configs
  depends_on = [google_project_service.apis] # Ensure APIs are enabled first  
  project_id   = each.value.project_id
  network_name = each.value.network_name
  routing_mode = "GLOBAL"
  subnets      = each.value.subnets
}

# --------------------
# 03-vpc-peering
# --------------------
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

# --------------------
# 04-cloud-nat
# --------------------
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
  for_each = google_compute_router.nat_router
  name     = "${each.key}-nat-gateway-${var.region}"
  router   = each.value.name
  region   = each.value.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = each.value.project
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# --------------------
# 05-cloud-dns
# --------------------
resource "google_dns_managed_zone" "hub_forwarding_zone" {
  project     = var.projects["hub_project"].project_id
  name        = var.hub_dns_zone_name
  dns_name    = "${var.domain_name}."
  description = "Hub forwarding zone"
  visibility  = "private"
  private_visibility_config {
    networks {
      network_url = module.vpcs["hub"].network_self_link
    }
  }
  forwarding_config {
    dynamic "target_name_servers" {
      for_each = var.dns_server_ips
      content {
        ipv4_address = target_name_servers.value
      }
    }
  }
}

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

resource "google_dns_managed_zone" "spoke_peering_zone" {
  for_each    = local.spoke_configs
  project     = each.value.project_id
  name        = "${var.hub_dns_zone_name}-${each.key}-peering"
  dns_name    = "${var.domain_name}."
  description = "Spoke ${each.key} peering zone to Hub forwarding zone"
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

# --------------------
# 06-gce-vms
# --------------------
resource "google_compute_instance" "vm-hub-cli1" {
  project      = var.projects["hub_project"].project_id
  zone         = "${var.region}-a"
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
    network_ip = "10.0.0.31" // TBD: move to variables.tfvars
  }
  shielded_instance_config {
    enable_secure_boot = true // TBD: move to variables.tfvars
  }
  metadata_startup_script = "#!/bin/bash\n echo 'Hub Base VM created!'"
  //tags                    = ["http-server", "https-server", "hub-vm"]
  params {
    resource_manager_tags = {
      (google_tags_tag_key.security_role_tag_key.id) = google_tags_tag_value.ssh_via_iap_tag_value.id
    }
  }
}

resource "google_compute_instance" "vm-hub-www1" {
  project      = var.projects["hub_project"].project_id
  zone         = "${var.region}-b"
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
    network_ip = "10.0.0.21" // TBD: move to variables.tfvars
  }
  shielded_instance_config {
    enable_secure_boot = true // TBD: move to variables.tfvars
  }
  // TBD: Analyze if it is better to compile the commands onto a file or template
  metadata_startup_script = "#!/bin/bash\n sudo apt-get update && sudo apt-get install -y apache2 && echo 'Hello from Hub Web Server!' | sudo tee /var/www/html/index.html"
  //tags                    = ["http-server", "https-server", "web-server"]
  params {
    resource_manager_tags = {
      (google_tags_tag_key.security_role_tag_key.id) = google_tags_tag_value.ssh_via_iap_tag_value.id
    }
  }
}

resource "google_compute_instance" "hub_dns_server_vms" {
  for_each     = var.dns_server_ips
  project      = var.projects["hub_project"].project_id
  zone         = "${var.region}-${each.key == "dns-01" ? "a" : "b"}"
  name         = "hub-${each.key}-vm"
  machine_type = var.hub_vm_machine_type
  boot_disk {
    initialize_params {
      image = var.instance_image 
    }
  }
  network_interface {
    network    = module.vpcs["hub"].network_self_link
    subnetwork = module.vpcs["hub"].subnets["${var.region}/${var.hub_subnet_name}"].self_link
    network_ip = each.value
  }
  shielded_instance_config {
    enable_secure_boot = true // TBD: move to variables.tfvars
  }
    // TBD: Analyze if it is better to compile the commands onto a file or template
  metadata = {
    startup-script = <<-EOT
      #! /bin/bash
      set -euo pipefail

      # 1. Update and Upgrade the system packages
      echo "Updating system packages..."
      sudo apt-get update
      sudo apt-get upgrade -y

      # 2. Install BIND9 and utility packages
      echo "Installing BIND9..."
      sudo apt-get install -y bind9 bind9utils bind9-doc

      # 3. Create the forward lookup zone file for acme.local
      echo "Creating forward zone file /etc/bind/db.fwd.acme.local..."
      sudo tee /etc/bind/db.fwd.acme.local > /dev/null <<'EOF'
      ;
      ; BIND data file for acme.local
      ;
      $TTL    604800
      @       IN      SOA     acme.local. admin.acme.local. (
                                   3         ; Serial
                              604800         ; Refresh
                               86400         ; Retry
                             2419200         ; Expire
                              604800 )       ; Negative Cache TTL
      ;
      @       IN      NS      dns1
      @       IN      NS      dns2
      dns1    IN      A       10.0.0.11
      dns2    IN      A       10.0.0.12
      www1    IN      A       10.0.0.21
      EOF

      # 4. Add the zone configuration to the BIND main configuration file
      echo "Updating /etc/bind/named.conf.local with new zone..."
      sudo tee -a /etc/bind/named.conf.local > /dev/null <<'EOF'

      zone "acme.local" IN {
        type master ;
        file "/etc/bind/db.fwd.acme.local" ;
        allow-update { none; } ;
      } ;
      EOF

      # 5. Restart the BIND9 service to apply changes
      echo "Restarting BIND9 service..."
      sudo systemctl restart named.service

      echo "DNS Server configuration complete."
    EOT
  }
  //metadata_startup_script = "#!/bin/bash\n echo 'Hub ${each.key} DNS VM created!'"
  //  tags                    = ["dns-server", "hub-vm"]
  params {
    resource_manager_tags = {
      (google_tags_tag_key.security_role_tag_key.id) = google_tags_tag_value.ssh_via_iap_tag_value.id
    }
  }
}



resource "google_compute_instance" "spoke_prd_cli_vms" {
  for_each = var.spoke_prd_cli_vms

  project      = var.projects["spoke_prd_project"].project_id
  zone         = "${var.region}-${each.value.zone_suffix}"
  name         = each.key # Uses the map key e.g., "vm-prd-cli1"
  machine_type = var.spoke_prd_vm_machine_type

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    network    = module.vpcs["spoke_prd"].network_self_link
    subnetwork = module.vpcs["spoke_prd"].subnets["${var.region}/${var.spoke_prd_subnet_name}"].self_link
    //network_ip = each.value.ip_address # Assigns the fixed IP
  }

  shielded_instance_config {
    enable_secure_boot = true
  }

  metadata_startup_script = "#!/bin/bash\n echo 'Spoke PRD ${each.key} VM created!'"
  //  tags                    = ["spoke-prd-vm", "cli-vm"]
  params {
    resource_manager_tags = {
      (google_tags_tag_key.security_role_tag_key.id) = google_tags_tag_value.ssh_via_iap_tag_value.id
    }
  }
}


resource "google_compute_instance" "spoke_dev_cli_vms" {
  for_each = var.spoke_dev_cli_vms

  project      = var.projects["spoke_dev_project"].project_id
  zone         = "${var.region}-${each.value.zone_suffix}"
  name         = each.key # Uses the map key e.g., "vm-dev-cli1"
  machine_type = var.spoke_dev_vm_machine_type

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    network    = module.vpcs["spoke_dev"].network_self_link
    subnetwork = module.vpcs["spoke_dev"].subnets["${var.region}/${var.spoke_dev_subnet_name}"].self_link
    //network_ip = each.value.ip_address # Assigns the fixed IP
  }

  shielded_instance_config {
    enable_secure_boot = true
  }
  metadata_startup_script = "#!/bin/bash\n echo 'Spoke DEV ${each.key} VM created!'"
  //tags                    = ["spoke-dev-vm", "cli-vm"]
  params {
    resource_manager_tags = {
      (google_tags_tag_key.security_role_tag_key.id) = google_tags_tag_value.ssh_via_iap_tag_value.id
    }
  }
}


# --------------------
# 07-firewall-rules
# --------------------
locals {
  project_firewall_configs = {
    "hub" = {
      project_id    = var.projects["hub_project"].project_id
      vpc_self_link = module.vpcs["hub"].network_self_link
    },
    "spoke-prd" = {
      project_id    = var.projects["spoke_prd_project"].project_id
      vpc_self_link = module.vpcs["spoke_prd"].network_self_link
    },
    "spoke-dev" = {
      project_id    = var.projects["spoke_dev_project"].project_id
      vpc_self_link = module.vpcs["spoke_dev"].network_self_link
    }
  }
}

resource "google_tags_tag_key" "environment_tag_key" {
  parent      = "organizations/${var.organization_id}"
  short_name  = "environment"
  description = "Environment for the resource (e.g., prd, dev)"
  purpose     = "GCE_FIREWALL"
  /*purpose_data = {
    network = "${var.projects["hub_project"].project_id}/${var.hub_vpc_name}"
  }*/
  purpose_data = {
    organization = "auto"
  }
  depends_on = [google_project_service.apis]
}

resource "google_tags_tag_key" "application_role_tag_key" {
  parent      = "organizations/${var.organization_id}"
  short_name  = "app-role"
  description = "Role of the application (e.g., web-server, dns-server)"
  purpose     = "GCE_FIREWALL"
  purpose_data = {
    organization = "auto"
  }
  depends_on = [google_project_service.apis]
}

resource "google_tags_tag_key" "security_role_tag_key" {
  parent      = "organizations/${var.organization_id}"
  short_name  = "security-role"
  description = "Defines a specific security purpose for a resource"
  purpose     = "GCE_FIREWALL"
  purpose_data = {
    organization = "auto"
  }
  depends_on = [google_project_service.apis]
}

resource "google_tags_tag_value" "env_prd_tag_value" {
  parent      = google_tags_tag_key.environment_tag_key.id
  short_name  = "prd"
  description = "Production Environment"
}

resource "google_tags_tag_value" "app_web_server_tag_value" {
  parent      = google_tags_tag_key.application_role_tag_key.id
  short_name  = "web-server"
  description = "Web Server Role"
}

resource "google_tags_tag_value" "ssh_via_iap_tag_value" {
  parent      = google_tags_tag_key.security_role_tag_key.id
  short_name  = "ssh-via-iap"
  description = "Allows SSH ingress from the Google IAP proxy service"
}

resource "google_compute_network_firewall_policy" "project_policies" {
  for_each    = local.project_firewall_configs
  project     = each.value.project_id
  name        = "${each.key}-firewall-policy"
  description = "Global firewall policy for ${each.key} project"
}

resource "google_compute_network_firewall_policy_association" "project_policy_associations" {
  provider          = google-beta
  for_each          = local.project_firewall_configs
  project           = each.value.project_id
  name              = "${each.key}-policy-association"
  attachment_target = each.value.vpc_self_link
  firewall_policy   = google_compute_network_firewall_policy.project_policies[each.key].name
}

resource "google_compute_network_firewall_policy_rule" "allow_ssh_via_iap" {
  for_each        = local.project_firewall_configs
  project         = each.value.project_id
  firewall_policy = google_compute_network_firewall_policy.project_policies[each.key].name
  rule_name       = "allow-ssh-via-iap"
  priority        = 990 # High priority
  direction       = "INGRESS"
  action          = "allow"
  description     = "Allow TCP:22 for SSH from Google's IAP service."

  match {
    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["22"]
    }
    # This is the specific IP range used by Google for IAP TCP forwarding.
    src_ip_ranges = ["35.235.240.0/20"]
  }

  # This targets the rule to any VM with the "ssh-via-iap" secure tag.
  target_secure_tags {
    name = google_tags_tag_value.ssh_via_iap_tag_value.id
  }
}

resource "google_compute_network_firewall_policy_rule" "allow_http_https_to_web_servers" {
  for_each        = local.project_firewall_configs
  project         = each.value.project_id
  firewall_policy = google_compute_network_firewall_policy.project_policies[each.key].name
  rule_name       = "allow-http-https-to-web-servers"
  priority        = 1000
  direction       = "INGRESS"
  action          = "allow"
  description     = "Allow HTTP/S access to web servers."
  match {
    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["80", "443"]
    }
    src_ip_ranges = [
      module.vpcs["hub"].subnets["${var.region}/${var.hub_subnet_name}"].ip_cidr_range
    ]
  }
  dynamic "target_secure_tags" {
    for_each = ["${google_tags_tag_value.app_web_server_tag_value.id}"]
    content {
      name = target_secure_tags.value
    }
  }
}

resource "google_compute_network_firewall_policy_rule" "allow_spoke_to_dns_servers" {
  for_each        = local.project_firewall_configs
  project         = each.value.project_id
  firewall_policy = google_compute_network_firewall_policy.project_policies[each.key].name
  rule_name       = "allow-spoke-to-dns-servers"
  priority        = 1010
  direction       = "INGRESS"
  action          = "allow"
  description     = "Allow DNS traffic from spoke networks to DNS servers."
  match {
    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["53"]
    }
    layer4_configs {
      ip_protocol = "udp"
      ports       = ["53"]
    }
    src_ip_ranges = [
      module.vpcs["hub"].subnets["${var.region}/${var.hub_subnet_name}"].ip_cidr_range,
      module.vpcs["spoke_prd"].subnets["${var.region}/${var.spoke_prd_subnet_name}"].ip_cidr_range,
      module.vpcs["spoke_dev"].subnets["${var.region}/${var.spoke_dev_subnet_name}"].ip_cidr_range
    ]
  }
}

