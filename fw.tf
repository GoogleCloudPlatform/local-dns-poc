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
      module.vpcs["spoke_dev"].subnets["${var.region}/${var.spoke_dev_subnet_name}"].ip_cidr_range,
      "35.199.192.0/19" # Google Cloud DNS IP range
    ]
  }
}