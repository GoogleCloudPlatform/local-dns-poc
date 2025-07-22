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
  type        = string
}

variable "project_id_prd" {
  description = "Production project id."
  type        = string
}

variable "project_id_dev" {
  description = "Development project id"
  type        = string
}

variable "vpc_name_hub" {
  description = "The name for the hub VPC."
  type        = string
}

variable "vpc_name_prd" {
  description = "The name for the production VPC."
  type        = string
}

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
