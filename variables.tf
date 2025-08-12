# variables.tf

variable "gcs_bucket_name" {
  description = "The globally unique name for the GCS bucket for Terraform state."
  type        = string
}

variable "gcs_bucket_project_id" {
  description = "The ID of the project where the GCS bucket will be created."
  type        = string
}

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
  type        = string
}

variable "organization_id" {
  description = "The ID of the GCP organization."
  type        = string
}

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
  type        = string
}

variable "gcp_dns_server_ips" {
  description = "List of IP addresses for your on-premises DNS servers."
  type        = list(string)
  default     = ["10.0.0.11", "10.0.0.12"]
}