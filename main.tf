<<<<<<< PATCH SET (8f72f2bf0322938c6622cf1e932a9f07be04b8b2 Modified GCE, DNS, and Firewall configs.)
/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may
 a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
||||||| BASE      (ba02395fa8d6cee6158d1bf091f6e2e358719d53 Add VPCs and subnets creation)
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
=======
# --------------------
# 01-gcp-projects
# --------------------
module "gcp_projects" {
  source          = "terraform-google-modules/project-factory/google"
  version         = "18.0.0"
>>>>>>> BASE      (3c32fa222f2d37b5b3145be1b29ad23bb446fa2d Single state Terraform codebase)

<<<<<<< PATCH SET (8f72f2bf0322938c6622cf1e932a9f07be04b8b2 Modified GCE, DNS, and Firewall configs.)
# --------------------
# 01-gcp-api-enablement
# --------------------
||||||| BASE      (ba02395fa8d6cee6158d1bf091f6e2e358719d53 Add VPCs and subnets creation)

# Local variables to create a map from the input lists.
# This makes it easier to iterate over the projects and their associated network configurations.
=======
  for_each        = var.projects

  project_id      = each.value.project_id
  name            = each.value.project_name
  billing_account = var.billing_account_id
  org_id          = var.organization_id
  folder_id       = each.value.folder_id
  deletion_policy = "DELETE"
  activate_apis   = each.value.activate_apis
}

# --------------------
# 02-vpc-networks
# --------------------
# This block uses a single module and a local variable to create all VPCs.
>>>>>>> BASE      (3c32fa222f2d37b5b3145be1b29ad23bb446fa2d Single state Terraform codebase)
locals {
<<<<<<< PATCH SET (8f72f2bf0322938c6622cf1e932a9f07be04b8b2 Modified GCE, DNS, and Firewall configs.)
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
||||||| BASE      (ba02395fa8d6cee6158d1bf091f6e2e358719d53 Add VPCs and subnets creation)
=======
  network_configs = {
    hub = {
      project_id    = module.gcp_projects["hub_project"].project_id
      network_name  = var.hub_vpc_name
>>>>>>> BASE      (3c32fa222f2d37b5b3145be1b29ad23bb446fa2d Single state Terraform codebase)
      subnets = [{
        subnet_name   = var.hub_subnet_name
        subnet_ip     = var.hub_subnet_ip
        subnet_region = var.region
      }]
    },
    spoke_prd = {
<<<<<<< PATCH SET (8f72f2bf0322938c6622cf1e932a9f07be04b8b2 Modified GCE, DNS, and Firewall configs.)
      project_id   = var.projects["spoke_prd_project"].project_id
      network_name = var.spoke_prd_vpc_name
||||||| BASE      (ba02395fa8d6cee6158d1bf091f6e2e358719d53 Add VPCs and subnets creation)
=======
      project_id    = module.gcp_projects["spoke_prd_project"].project_id
      network_name  = var.spoke_prd_vpc_name
>>>>>>> BASE      (3c32fa222f2d37b5b3145be1b29ad23bb446fa2d Single state Terraform codebase)
      subnets = [{
        subnet_name   = var.spoke_prd_subnet_name
        subnet_ip     = var.spoke_prd_subnet_ip
        subnet_region = var.region
      }]
    },
    spoke_dev = {
<<<<<<< PATCH SET (8f72f2bf0322938c6622cf1e932a9f07be04b8b2 Modified GCE, DNS, and Firewall configs.)
      project_id   = var.projects["spoke_dev_project"].project_id
      network_name = var.spoke_dev_vpc_name
||||||| BASE      (ba02395fa8d6cee6158d1bf091f6e2e358719d53 Add VPCs and subnets creation)
=======
      project_id    = module.gcp_projects["spoke_dev_project"].project_id
      network_name  = var.spoke_dev_vpc_name
>>>>>>> BASE      (3c32fa222f2d37b5b3145be1b29ad23bb446fa2d Single state Terraform codebase)
      subnets = [{
        subnet_name   = var.spoke_dev_subnet_name
        subnet_ip     = var.spoke_dev_subnet_ip
        subnet_region = var.region
      }]
    }
  }
}

module "vpcs" {
  source       = "terraform-google-modules/network/google"
  version      = "11.1.1"
  for_each     = local.network_configs
<<<<<<< PATCH SET (8f72f2bf0322938c6622cf1e932a9f07be04b8b2 Modified GCE, DNS, and Firewall configs.)
  depends_on   = [google_project_service.apis] # Ensure APIs are enabled first
||||||| BASE      (ba02395fa8d6cee6158d1bf091f6e2e358719d53 Add VPCs and subnets creation)
  version = "~> 9.0"
=======
>>>>>>> BASE      (3c32fa222f2d37b5b3145be1b29ad23bb446fa2d Single state Terraform codebase)

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
<<<<<<< PATCH SET (8f72f2bf0322938c6622cf1e932a9f07be04b8b2 Modified GCE, DNS, and Firewall configs.)

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
    network_ip = "10.0.0.31"
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
  metadata_startup_script = "#!/bin/bash\n echo 'Hub Base VM created!'"
  //tags                    = ["http-server", "https-server", "hub-vm"]
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
    network_ip = "10.0.0.21"
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
  metadata_startup_script = "#!/bin/bash\n sudo apt-get update && sudo apt-get install -y apache2 && echo 'Hello from Hub Web Server!' | sudo tee /var/www/html/index.html"
  //tags                    = ["http-server", "https-server", "web-server"]
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
    enable_secure_boot = true
  }
  metadata_startup_script = "#!/bin/bash\n echo 'Hub ${each.key} DNS VM created!'"
//  tags                    = ["dns-server", "hub-vm"]
}
/*
resource "google_compute_instance" "spoke_prd_vms" {
  for_each     = toset(["instance-01", "instance-02"])
  project      = var.projects["spoke_prd_project"].project_id
  zone         = "${var.region}-${each.key == "instance-01" ? "a" : "b"}"
  name         = "spoke-prd-${each.key}"
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
    enable_secure_boot = true
  }
  metadata_startup_script = "#!/bin/bash\n echo 'Spoke PRD ${each.key} VM created!'"
  tags                    = ["spoke-prd-vm"]
}
*/


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
    network_ip = each.value.ip_address # Assigns the fixed IP
  }

  shielded_instance_config {
    enable_secure_boot = true
  }

  metadata_startup_script = "#!/bin/bash\n echo 'Spoke PRD ${each.key} VM created!'"
//  tags                    = ["spoke-prd-vm", "cli-vm"]
}

/*
resource "google_compute_instance" "spoke_dev_vms" {
  for_each     = toset(["instance-01", "instance-02"])
  project      = var.projects["spoke_dev_project"].project_id
  zone         = "${var.region}-${each.key == "instance-01" ? "a" : "b"}"
  name         = "spoke-dev-${each.key}"
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
    enable_secure_boot = true
  }
  metadata_startup_script = "#!/bin/bash\n echo 'Spoke DEV ${each.key} VM created!'"
  tags                    = ["spoke-dev-vm"]
}
*/

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
    network_ip = each.value.ip_address # Assigns the fixed IP
  }

  shielded_instance_config {
    enable_secure_boot = true
  }

  metadata_startup_script = "#!/bin/bash\n echo 'Spoke DEV ${each.key} VM created!'"
  //tags                    = ["spoke-dev-vm", "cli-vm"]
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
  provider    = google-beta
  parent      = "organizations/${var.organization_id}"
  short_name  = "environment"
  description = "Environment for the resource (e.g., prd, dev)"
  purpose     = "GCE_FIREWALL"
  purpose_data = {
    network = "${var.projects["hub_project"].project_id}/${var.hub_vpc_name}"
  }
  depends_on = [google_project_service.apis]
}

resource "google_tags_tag_key" "application_role_tag_key" {
  provider    = google-beta
  parent      = "organizations/${var.organization_id}"
  short_name  = "app-role"
  description = "Role of the application (e.g., web-server, dns-server)"
  purpose     = "GCE_FIREWALL"
  purpose_data = {
    network = "${var.projects["hub_project"].project_id}/${var.hub_vpc_name}"
  }
  depends_on = [google_project_service.apis]
}

resource "google_tags_tag_value" "env_prd_tag_value" {
  provider    = google-beta
  parent      = google_tags_tag_key.environment_tag_key.id
  short_name  = "prd"
  description = "Production Environment"
}

resource "google_tags_tag_value" "app_web_server_tag_value" {
  provider    = google-beta
  parent      = google_tags_tag_key.application_role_tag_key.id
  short_name  = "web-server"
  description = "Web Server Role"
}

resource "google_compute_network_firewall_policy" "project_policies" {
  provider    = google-beta
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

resource "google_compute_network_firewall_policy_rule" "allow_http_https_to_web_servers" {
  provider        = google-beta
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
  provider        = google-beta
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
||||||| BASE      (ba02395fa8d6cee6158d1bf091f6e2e358719d53 Add VPCs and subnets creation)
=======
# --------------------
# 04-cloud-nat
# --------------------
locals {
  nat_configs = {
    "hub" = {
      project_id        = module.gcp_projects["hub_project"].project_id
      network_self_link = module.vpcs["hub"].network_self_link
    },
    "spoke-prd" = {
      project_id        = module.gcp_projects["spoke_prd_project"].project_id
      network_self_link = module.vpcs["spoke_prd"].network_self_link
    },
    "spoke-dev" = {
      project_id        = module.gcp_projects["spoke_dev_project"].project_id
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

# --------------------
# 05-cloud-dns
# --------------------
resource "google_dns_managed_zone" "hub_forwarding_zone" {
  project     = module.gcp_projects["hub_project"].project_id
  name        = var.hub_dns_zone_name
  dns_name    = "${var.domain_name}."
  description = "Hub forwarding zone for on-premises DNS resolution"
  visibility  = "private"
  private_visibility_config {
    networks {
      network_url = module.vpcs["hub"].network_self_link
    }
  }
  forwarding_config {
    dynamic "target_name_servers" {
      for_each = var.gcp_dns_server_ips
      content {
        ipv4_address = target_name_servers.value
      }
    }
  }
}

locals {
  spoke_configs = {
    "prd" = {
      project_id    = module.gcp_projects["spoke_prd_project"].project_id
      vpc_self_link = module.vpcs["spoke_prd"].network_self_link
    },
    "dev" = {
      project_id    = module.gcp_projects["spoke_dev_project"].project_id
      vpc_self_link = module.vpcs["spoke_dev"].network_self_link
    },
  }
}

resource "google_dns_managed_zone" "spoke_peering_zone" {
  for_each = local.spoke_configs
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
resource "google_compute_instance" "hub_base_vm" {
  project      = module.gcp_projects["hub_project"].project_id
  zone         = "${var.region}-a"
  name         = "hub-base-vm"
  machine_type = var.hub_vm_machine_type
  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }
  network_interface {
    network    = module.vpcs["hub"].network_self_link
    subnetwork = module.vpcs["hub"].subnets["${var.region}/${var.hub_subnet_name}"].self_link
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
  metadata_startup_script = "#!/bin/bash\n echo 'Hub Base VM created!'"
  tags                    = ["http-server", "https-server", "hub-vm"]
}

resource "google_compute_instance" "hub_web_server_vm" {
  project      = module.gcp_projects["hub_project"].project_id
  zone         = "${var.region}-b"
  name         = "hub-web-server-vm"
  machine_type = var.hub_vm_machine_type
  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }
  network_interface {
    network    = module.vpcs["hub"].network_self_link
    subnetwork = module.vpcs["hub"].subnets["${var.region}/${var.hub_subnet_name}"].self_link
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
  metadata_startup_script = "#!/bin/bash\n sudo apt-get update && sudo apt-get install -y apache2 && echo 'Hello from Hub Web Server!' | sudo tee /var/www/html/index.html"
  tags                    = ["http-server", "https-server", "web-server"]
}

resource "google_compute_instance" "hub_dns_server_vms" {
  for_each = toset(["dns-01", "dns-02"])
  project      = module.gcp_projects["hub_project"].project_id
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
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
  metadata_startup_script = "#!/bin/bash\n echo 'Hub ${each.key} DNS VM created!'"
  tags                    = ["dns-server", "hub-vm"]
}

resource "google_compute_instance" "spoke_prd_vms" {
  for_each = toset(["instance-01", "instance-02"])
  project      = module.gcp_projects["spoke_prd_project"].project_id
  zone         = "${var.region}-${each.key == "instance-01" ? "a" : "b"}"
  name         = "spoke-prd-${each.key}"
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
    enable_secure_boot = true
  }
  metadata_startup_script = "#!/bin/bash\n echo 'Spoke PRD ${each.key} VM created!'"
  tags                    = ["spoke-prd-vm"]
}

resource "google_compute_instance" "spoke_dev_vms" {
  for_each = toset(["instance-01", "instance-02"])
  project      = module.gcp_projects["spoke_dev_project"].project_id
  zone         = "${var.region}-${each.key == "instance-01" ? "a" : "b"}"
  name         = "spoke-dev-${each.key}"
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
    enable_secure_boot = true
  }
  metadata_startup_script = "#!/bin/bash\n echo 'Spoke DEV ${each.key} VM created!'"
  tags                    = ["spoke-dev-vm"]
}

# --------------------
# 07-firewall-rules (Refactored)
# --------------------

# --- Local variable to map projects for iteration ---
locals {
  project_firewall_configs = {
    "hub" = {
      project_id  = module.gcp_projects["hub_project"].project_id
      vpc_self_link = module.vpcs["hub"].network_self_link
    },
    "spoke-prd" = {
      project_id  = module.gcp_projects["spoke_prd_project"].project_id
      vpc_self_link = module.vpcs["spoke_prd"].network_self_link
    },
    "spoke-dev" = {
      project_id  = module.gcp_projects["spoke_dev_project"].project_id
      vpc_self_link = module.vpcs["spoke_dev"].network_self_link
    }
  }
}

# --- Define Secure Tag Keys (Organization-level) with GCE_FIREWALL purpose ---
resource "google_tags_tag_key" "environment_tag_key" {
  provider     = google-beta
  parent       = "organizations/${var.organization_id}"
  short_name   = "environment"
  description  = "Environment for the resource (e.g., prd, dev)"
  purpose      = "GCE_FIREWALL"
  purpose_data = {
    network = "${module.gcp_projects["hub_project"].project_id}/${var.hub_vpc_name}"
  }
}

resource "google_tags_tag_key" "application_role_tag_key" {
  provider     = google-beta
  parent       = "organizations/${var.organization_id}"
  short_name   = "app-role"
  description  = "Role of the application (e.g., web-server, dns-server)"
  purpose      = "GCE_FIREWALL"
  purpose_data = {
    network = "${module.gcp_projects["hub_project"].project_id}/${var.hub_vpc_name}"
  }
}

# --- Define Secure Tag Values at the organization level ---
resource "google_tags_tag_value" "env_prd_tag_value" {
  provider    = google-beta
  parent      = google_tags_tag_key.environment_tag_key.id
  short_name  = "prd"
  description = "Production Environment"
}

resource "google_tags_tag_value" "app_web_server_tag_value" {
  provider    = google-beta
  parent      = google_tags_tag_key.application_role_tag_key.id
  short_name  = "web-server"
  description = "Web Server Role"
}

# --- Create a global network firewall policy for each project ---
resource "google_compute_network_firewall_policy" "project_policies" {
  provider    = google-beta
  for_each    = local.project_firewall_configs
  project     = each.value.project_id
  name        = "${each.key}-firewall-policy"
  description = "Global firewall policy for ${each.key} project"
}

# --- Associate each policy with its respective VPC network ---
resource "google_compute_network_firewall_policy_association" "project_policy_associations" {
  provider          = google-beta
  for_each          = local.project_firewall_configs
  project           = each.value.project_id
  name              = "${each.key}-policy-association"
  attachment_target = each.value.vpc_self_link
  firewall_policy   = google_compute_network_firewall_policy.project_policies[each.key].name
}

# --- Define rules for HTTP/S traffic ---
resource "google_compute_network_firewall_policy_rule" "allow_http_https_to_web_servers" {
  provider        = google-beta
  for_each        = local.project_firewall_configs
  project         = each.value.project_id
  firewall_policy = google_compute_network_firewall_policy.project_policies[each.key].name
  rule_name       = "allow-http-https-to-web-servers"
  priority        = 1000
  direction       = "INGRESS"
  action          = "allow"
  description     = "Allow public HTTP/S access to web servers."
  match {
    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["80", "443"]
    }
    src_ip_ranges = ["0.0.0.0/0"]
  }
  dynamic "target_secure_tags" {
    for_each = ["${google_tags_tag_value.app_web_server_tag_value.id}"]
    content {
      name = target_secure_tags.value
    }
  }
}

# --- Define rules for DNS traffic ---
resource "google_compute_network_firewall_policy_rule" "allow_spoke_to_dns_servers" {
  provider        = google-beta
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
  # Assuming a tag value for DNS servers exists
  # dynamic "target_secure_tags" {
  #   for_each = ["<your_dns_tag_value_id_here>"]
  #   content {
  #     name = target_secure_tags.value
  #   }
  # }
>>>>>>> BASE      (3c32fa222f2d37b5b3145be1b29ad23bb446fa2d Single state Terraform codebase)
}