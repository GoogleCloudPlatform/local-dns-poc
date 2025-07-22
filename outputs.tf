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

output "vpc_details" {
  description = "Details of the created VPC networks."
  value = {
    for k, vpc in module.vpc : k => {
      project_id   = vpc.project_id
      network_name = vpc.network_name
      network_id   = vpc.network_id
    }
  }
}

output "subnet_details" {
  description = "Details of the created subnets."
  value = {
    for k, vpc in module.vpc : k => {
      for i, subnet in vpc.subnets : "${k}-${i}" => {
        project_id    = vpc.project_id
        subnet_name   = subnet.name
        subnet_id     = subnet.id
        ip_cidr_range = subnet.ip_cidr_range
      }
    }
  }
}
