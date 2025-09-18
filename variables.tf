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

# --------------------
# Provider Configuration
# --------------------
variable "organization_id" {
  description = "The ID of the GCP organization (e.g., '123456789012')."
  type        = string
}

variable "domain_name" {
  description = "The FQDN of your domain (e.g., 'your-company.com')."
  type        = string
}

# --------------------
# Project Configuration
# --------------------
variable "projects" {
  description = "A map of logical project names to their details, including the actual GCP project ID and a list of APIs to enable."
  type = map(object({
    project_id = string
    apis       = list(string)
  }))
}

# --------------------
# Network & Compute Configuration
# --------------------
variable "region" {
  description = "The GCP region for the subnets and VMs."
  type        = string
  default     = "us-central1"
}

variable "hub_vpc_name" {
  description = "The name for the Hub VPC network."
  type        = string
  default     = "hub-vpc"
}

variable "hub_subnet_name" {
  description = "The name for the Hub subnet."
  type        = string
  default     = "hub-subnet-01"
}

variable "hub_subnet_ip" {
  description = "The IP range for the Hub subnet."
  type        = string
  default     = "10.0.0.0/24"
}

variable "spoke_prd_vpc_name" {
  description = "The name for the Spoke PRD VPC network."
  type        = string
  default     = "spoke-prd-vpc"
}

variable "spoke_prd_subnet_name" {
  description = "The name for the Spoke PRD subnet."
  type        = string
  default     = "spoke-prd-subnet-01"
}

variable "spoke_prd_subnet_ip" {
  description = "The IP range for the Spoke PRD subnet."
  type        = string
  default     = "10.1.0.0/24"
}

variable "spoke_dev_vpc_name" {
  description = "The name for the Spoke DEV VPC network."
  type        = string
  default     = "spoke-dev-vpc"
}

variable "spoke_dev_subnet_name" {
  description = "The name for the Spoke DEV subnet."
  type        = string
  default     = "spoke-dev-subnet-01"
}

variable "spoke_dev_subnet_ip" {
  description = "The IP range for the Spoke DEV subnet."
  type        = string
  default     = "10.2.0.0/24"
}

variable "instance_image" {
  description = "The OS image for the VMs."
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "hub_vm_machine_type" {
  description = "Machine type for Hub VMs."
  type        = string
  default     = "e2-medium"
}

variable "spoke_prd_vm_machine_type" {
  description = "Machine type for Spoke PRD VMs."
  type        = string
  default     = "e2-medium"
}

variable "spoke_dev_vm_machine_type" {
  description = "Machine type for Spoke DEV VMs."
  type        = string
  default     = "e2-small"
}

variable "enable_secure_boot" {
  description = "If true, enables Secure Boot on Shielded VM instances."
  type        = bool
  default     = true
}

variable "hub_www1_ip" {
  description = "The internal IP address for the vm-hub-www1 instance."
  type        = string
  default     = "10.0.0.21"
}

# --------------------
# DNS Configuration
# --------------------
variable "hub_dns_zone_name" {
  description = "The name for the Hub's private forwarding DNS zone."
  type        = string
  default     = "onprem-forwarder"
}

variable "dns_server_ips" {
  description = "A map of DNS server identifiers to their fixed internal IP addresses."
  type        = map(string)
  default = {
    "vm-hub-dns1" = "10.0.0.11"
    "vm-hub-dns2" = "10.0.0.12"
  }
}

variable "spoke_prd_cli_vms" {
  description = "A map of production client VMs to create, with their specific IP and zone."
  type = map(object({
    ip_address  = string
    zone_suffix = string
  }))
  default = {}
}

variable "spoke_dev_cli_vms" {
  description = "A map of development client VMs to create, with their specific IP and zone."
  type = map(object({
    ip_address  = string
    zone_suffix = string
  }))
  default = {}
}
