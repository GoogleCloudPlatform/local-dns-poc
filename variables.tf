<<<<<<< PATCH SET (8f72f2bf0322938c6622cf1e932a9f07be04b8b2 Modified GCE, DNS, and Firewall configs.)
# --------------------
# Provider Configuration
# --------------------
variable "organization_id" {
  description = "The ID of the GCP organization (e.g., '123456789012')."
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

variable "project_id_hub" {
  description = "Hub project id."
=======
# variables.tf

variable "gcs_bucket_name" {
  description = "The globally unique name for the GCS bucket for Terraform state."
>>>>>>> BASE      (3c32fa222f2d37b5b3145be1b29ad23bb446fa2d Single state Terraform codebase)
  type        = string
}

<<<<<<< PATCH SET (8f72f2bf0322938c6622cf1e932a9f07be04b8b2 Modified GCE, DNS, and Firewall configs.)
variable "domain_name" {
  description = "The FQDN of your domain (e.g., 'your-company.com')."
||||||| BASE      (ba02395fa8d6cee6158d1bf091f6e2e358719d53 Add VPCs and subnets creation)
variable "project_id_prd" {
  description = "Production project id."
=======
variable "gcs_bucket_project_id" {
  description = "The ID of the project where the GCS bucket will be created."
>>>>>>> BASE      (3c32fa222f2d37b5b3145be1b29ad23bb446fa2d Single state Terraform codebase)
  type        = string
}

<<<<<<< PATCH SET (8f72f2bf0322938c6622cf1e932a9f07be04b8b2 Modified GCE, DNS, and Firewall configs.)
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
||||||| BASE      (ba02395fa8d6cee6158d1bf091f6e2e358719d53 Add VPCs and subnets creation)
variable "project_id_dev" {
  description = "Development project id"
=======
variable "gcs_bucket_location" {
  description = "The location (region or multi-region) for the GCS bucket."
  type        = string
  default     = "US-CENTRAL1"
}

variable "gcs_bucket_storage_class" {
  description = "The storage class for the GCS bucket."
  type        = string
  default     = "STANDARD"
}

variable "billing_account_id" {
  description = "The ID of the billing account to associate with all projects."
>>>>>>> BASE      (3c32fa222f2d37b5b3145be1b29ad23bb446fa2d Single state Terraform codebase)
  type        = string
  default     = "us-central1"
}

<<<<<<< PATCH SET (8f72f2bf0322938c6622cf1e932a9f07be04b8b2 Modified GCE, DNS, and Firewall configs.)
variable "hub_vpc_name" {
  description = "The name for the Hub VPC network."
||||||| BASE      (ba02395fa8d6cee6158d1bf091f6e2e358719d53 Add VPCs and subnets creation)
variable "vpc_name_hub" {
  description = "The name for the hub VPC."
=======
variable "organization_id" {
  description = "The ID of the GCP organization."
>>>>>>> BASE      (3c32fa222f2d37b5b3145be1b29ad23bb446fa2d Single state Terraform codebase)
  type        = string
  default     = "hub-vpc-network"
}

<<<<<<< PATCH SET (8f72f2bf0322938c6622cf1e932a9f07be04b8b2 Modified GCE, DNS, and Firewall configs.)
variable "hub_subnet_name" {
  description = "The name for the Hub subnet."
||||||| BASE      (ba02395fa8d6cee6158d1bf091f6e2e358719d53 Add VPCs and subnets creation)
variable "vpc_name_prd" {
  description = "The name for the production VPC."
=======
variable "projects" {
  description = "Map of project configurations for Hub and Spoke topology."
  type = map(object({
    project_id    = string
    project_name  = string
    folder_id     = string
    activate_apis = list(string)
  }))
}

variable "region" {
  description = "The GCP region for the subnets and VMs."
  type        = string
  default     = "us-central1"
}

variable "hub_vpc_name" {
  description = "The name for the Hub VPC network."
  type        = string
  default     = "hub-vpc-network"
}

variable "hub_subnet_name" {
  description = "The name for the Hub subnet."
  type        = string
  default     = "hub-subnet-01"
}

variable "hub_subnet_ip" {
  description = "The IP range for the Hub subnet."
  type = string
  default = "10.0.0.0/24"
}

variable "spoke_prd_vpc_name" {
  description = "The name for the Spoke PRD VPC network."
  type        = string
  default     = "spoke-prd-vpc-network"
}

variable "spoke_prd_subnet_name" {
  description = "The name for the Spoke PRD subnet."
  type        = string
  default     = "spoke-prd-subnet-01"
}

variable "spoke_prd_subnet_ip" {
  description = "The IP range for the Spoke PRD subnet."
  type = string
  default = "10.1.0.0/24"
}

variable "spoke_dev_vpc_name" {
  description = "The name for the Spoke DEV VPC network."
  type        = string
  default     = "spoke-dev-vpc-network"
}

variable "spoke_dev_subnet_name" {
  description = "The name for the Spoke DEV subnet."
  type        = string
  default     = "spoke-dev-subnet-01"
}

variable "spoke_dev_subnet_ip" {
  description = "The IP range for the Spoke DEV subnet."
  type = string
  default = "10.2.0.0/24"
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

variable "hub_dns_zone_name" {
  description = "The name for the Hub's private forwarding DNS zone."
  type        = string
  default     = "onprem-forwarder"
}

variable "domain_name" {
  description = "The FQDN of your domain."
>>>>>>> BASE      (3c32fa222f2d37b5b3145be1b29ad23bb446fa2d Single state Terraform codebase)
  type        = string
  default     = "hub-subnet-01"
}

<<<<<<< PATCH SET (8f72f2bf0322938c6622cf1e932a9f07be04b8b2 Modified GCE, DNS, and Firewall configs.)
variable "hub_subnet_ip" {
  description = "The IP range for the Hub subnet."
  type        = string
  default     = "10.0.0.0/24"
}

variable "spoke_prd_vpc_name" {
  description = "The name for the Spoke PRD VPC network."
  type        = string
  default     = "spoke-prd-vpc-network"
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
  default     = "spoke-dev-vpc-network"
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
    "dns-01" = "10.0.0.11"
    "dns-02" = "10.0.0.12"
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
||||||| BASE      (ba02395fa8d6cee6158d1bf091f6e2e358719d53 Add VPCs and subnets creation)
variable "vpc_name_dev" {
  description = "The name for the development VPC."
  type        = string
}

variable "subnet_hub" {
  description = "The configuration for the hub subnet."
  type = object({
    subnet_name           = string
    subnet_ip             = string
    subnet_region         = string
    subnet_private_access = optional(string)
    description           = optional(string)
  })
}

variable "subnet_prd" {
  description = "The configuration for the production subnet."
  type = object({
    subnet_name           = string
    subnet_ip             = string
    subnet_region         = string
    subnet_private_access = optional(string)
    description           = optional(string)
  })
}

variable "subnet_dev" {
  description = "The configuration for the development subnet."
  type = object({
    subnet_name           = string
    subnet_ip             = string
    subnet_region         = string
    subnet_private_access = optional(string)
    description           = optional(string)
  })
}

# variable "billing_account_id" {
#   description = "The ID of the billing account to associate with the new projects."
#   type        = string
# }
=======
variable "gcp_dns_server_ips" {
  description = "List of IP addresses for your on-premises DNS servers."
  type        = list(string)
  default     = ["10.0.0.11", "10.0.0.12"]
}
>>>>>>> BASE      (3c32fa222f2d37b5b3145be1b29ad23bb446fa2d Single state Terraform codebase)
