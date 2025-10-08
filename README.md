# Local DNS Terraform PoC

This Terraform code provides a standardized, well-documented, and easily deployable Infrastructure as Code (IaC) solution for integrating local DNS servers with Google Cloud. It automates the deployment of core GCP infrastructure, including local BIND DNS servers for a functional Proof of Concept (PoC). The solution addresses challenges faced by customers with strict compliance needs and intricate network designs, such as forwarding restrictions and multi-VPC outbound forwarding issues, aiming to reduce DNS query latency and provide a robust, standardized hub-and-spoke DNS integration.

## Architecture

This Terraform project deploys a PoC environment in Google Cloud to demonstrate a hybrid DNS resolution strategy. It establishes a hub-and-spoke network topology whith local BIND DNS servers which are deployed in the hub VPC, provide authoritative resolution for a specific domain and override specific public domains for private access, while forwarding all other queries.

The deployed architecture consists of the following key components:

1.  **Hub-and-Spoke Network**:
    *   A central **Hub VPC** that hosts shared services.
    *   Two **Spoke VPCs** (`prd` and `dev`) representing different environments.
    *   **VPC Peering** connects each spoke to the hub, allowing private communication.

2.  **Local DNS Resolution**:
    *   Two **BIND9 DNS servers** are deployed in the Hub VPC for high availability.
    *   These servers are authoritative for a custom internal domain (e.g., `acme.local`) and for `googleapis.com` to enable Private Google Access.
    *   A "catch-all" **Cloud DNS Forwarding Zone** (`.`) in the hub directs all DNS queries to the BIND servers.

3.  **DNS Peering**:
    *   The spoke networks are configured with **Cloud DNS Peering Zones** that point to the hub's forwarding zone, allowing VMs in the spokes to resolve names using the central BIND servers.

4.  **Secure Access and Firewall**:
    *   **Network Firewall Policies** and **Secure Tags** are used to enforce granular security rules.
    *   Rules are defined to allow SSH via IAP, HTTP/S to web servers, and DNS traffic to the BIND servers.

5.  **Compute Instances**:
    *   Various GCE instances are deployed across the hub and spokes to test connectivity and DNS resolution.
    *   Some spoke VMs are configured to use the central BIND servers, while others use the default VPC DNS resolver to demonstrate different resolution paths.

## Prerequisites

Before you begin, ensure you have the following:

*   Terraform v1.3+ installed.
*   A Google Cloud Organization, a valid billing account and a baseline project.
*   A dedicated identity with the necessary permissions:
    * Optional (for 00-state-bucket stage):
        * `roles/storage.admin` at the project where the state bucket will be created.
    * Required (for the entire solution):
        * At the organization level:
            * `roles/resourcemanager.tagAdmin`
            * `roles/resourcemanager.tagUser`
        * At the "hub," "spoke_prd," and "spoke_dev" projects levels:
            * `roles/serviceusage.serviceUsageAdmin`
            * `roles/compute.networkAdmin`
            * `roles/compute.instanceAdmin.v1`
            * `roles/dns.admin`
            * `roles/compute.securityAdmin`
            * `roles/iam.serviceAccountAdmin`
            * `roles/iam.serviceAccountUser`

## Deployment

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```

2.  **Optional: Create the TF state bucket:**
    Under the `00-state-bucket` folder, you will find out the Terraform code to create a GCS bucket (in a dedicated project) that will be used as a state backend for the solution.
    Create a `terraform.tfvars` file (use as a reference the `terraform.tfvars.example` file) and make sure to run the following commands under this folder:
    ```bash
    terraform init
    terraform apply
    ```

2.  **Update the backend.tf**
    Indicate a GCS bucket that will be used to store the TF state, manually update the `backend.tf` file and replace the `UPDATE_ME` string with the GCS bucket name.

2.  **Configure Variables:**
    Create a `terraform.tfvars` file and populate it with your desired configuration values for each one of the required inputs (use as a reference the `terraform.tfvars.example` file).

3.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

4.  **Apply the Configuration:**
    ```bash
    terraform apply
    ```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| google | >= 4.64, < 8 |
| google-beta | >= 4.64, < 8 |
| time | 0.9.1 |

## Providers

| Name | Version |
|------|---------|
| google | 6.44.0 |
| google-beta | 6.44.0 |
| time | 0.9.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| vpcs | terraform-google-modules/network/google | 11.1.1 |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_compute_network_firewall_policy_association.project_policy_associations](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_network_firewall_policy_association) | resource |
| [google_compute_instance.hub_dns_server_vms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.spoke_dev_cli_vms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.spoke_prd_cli_vms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.vm-hub-cli1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.vm-hub-www1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_network_firewall_policy.project_policies](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy) | resource |
| [google_compute_network_firewall_policy_rule.allow_http_https_to_web_servers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_rule) | resource |
| [google_compute_network_firewall_policy_rule.allow_spoke_to_dns_servers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_rule) | resource |
| [google_compute_network_firewall_policy_rule.allow_ssh_via_iap](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_rule) | resource |
| [google_compute_network_peering.hub_to_spoke_dev](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_network_peering.hub_to_spoke_prd](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_network_peering.spoke_dev_to_hub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_network_peering.spoke_prd_to_hub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_router.nat_router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat_gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_dns_managed_zone.hub_root_forwarding_zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_managed_zone.spoke_root_peering_zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_project_service.apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_tags_tag_key.application_role_tag_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_key) | resource |
| [google_tags_tag_key.environment_tag_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_key) | resource |
| [google_tags_tag_key.security_role_tag_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_key) | resource |
| [google_tags_tag_value.app_web_server_tag_value](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_value) | resource |
| [google_tags_tag_value.env_prd_tag_value](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_value) | resource |
| [google_tags_tag_value.ssh_via_iap_tag_value](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_value) | resource |
| [time_sleep.wait_for_vm_startup](https://registry.terraform.io/providers/hashicorp/time/0.9.1/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dns\_server\_vms | A map of DNS server identifiers to their fixed internal IP addresses. | <pre>map(object({<br/>    ip_address  = string<br/>    zone_suffix = string<br/>  }))</pre> | <pre>{<br/>  "vm-hub-dns1": {<br/>    "ip_address": "10.0.0.11",<br/>    "zone_suffix": "a"<br/>  },<br/>  "vm-hub-dns2": {<br/>    "ip_address": "10.0.0.12",<br/>    "zone_suffix": "b"<br/>  }<br/>}</pre> | no |
| domain\_name | The FQDN of your domain (e.g., 'your-company.com'). | `string` | n/a | yes |
| enable\_secure\_boot | If true, enables Secure Boot on Shielded VM instances. | `bool` | `true` | no |
| hub\_cli1\_vm | Configuration for the vm-hub-cli1 instance. | <pre>object({<br/>    ip_address  = string<br/>    zone_suffix = string<br/>  })</pre> | <pre>{<br/>  "ip_address": "10.0.0.31",<br/>  "zone_suffix": "a"<br/>}</pre> | no |
| hub\_dns\_zone\_name | The name for the Hub's private forwarding DNS zone. | `string` | `"onprem-forwarder"` | no |
| hub\_subnet\_ip | The IP range for the Hub subnet. | `string` | `"10.0.0.0/24"` | no |
| hub\_subnet\_name | The name for the Hub subnet. | `string` | `"hub-subnet-01"` | no |
| hub\_vm\_machine\_type | Machine type for Hub VMs. | `string` | `"e2-medium"` | no |
| hub\_vpc\_name | The name for the Hub VPC network. | `string` | `"hub-vpc"` | no |
| hub\_www1\_vm | Configuration for the vm-hub-www1 instance. | <pre>object({<br/>    ip_address  = string<br/>    zone_suffix = string<br/>  })</pre> | <pre>{<br/>  "ip_address": "10.0.0.21",<br/>  "zone_suffix": "b"<br/>}</pre> | no |
| instance\_image | The OS image for the VMs. | `string` | `"debian-cloud/debian-11"` | no |
| organization\_id | The ID of the GCP organization (e.g., '123456789012'). | `string` | n/a | yes |
| projects | A map of logical project names to their details, including the actual GCP project ID and a list of APIs to enable. | <pre>map(object({<br/>    project_id = string<br/>    apis       = list(string)<br/>  }))</pre> | n/a | yes |
| region | The GCP region for the subnets and VMs. | `string` | `"us-central1"` | no |
| spoke\_dev\_cli\_vms | A map of development client VMs to create, with their specific IP and zone. | <pre>map(object({<br/>    ip_address  = string<br/>    zone_suffix = string<br/>  }))</pre> | `{}` | no |
| spoke\_dev\_subnet\_ip | The IP range for the Spoke DEV subnet. | `string` | `"10.2.0.0/24"` | no |
| spoke\_dev\_subnet\_name | The name for the Spoke DEV subnet. | `string` | `"spoke-dev-subnet-01"` | no |
| spoke\_dev\_vm\_machine\_type | Machine type for Spoke DEV VMs. | `string` | `"e2-small"` | no |
| spoke\_dev\_vpc\_name | The name for the Spoke DEV VPC network. | `string` | `"spoke-dev-vpc"` | no |
| spoke\_prd\_cli\_vms | A map of production client VMs to create, with their specific IP and zone. | <pre>map(object({<br/>    ip_address  = string<br/>    zone_suffix = string<br/>  }))</pre> | `{}` | no |
| spoke\_prd\_subnet\_ip | The IP range for the Spoke PRD subnet. | `string` | `"10.1.0.0/24"` | no |
| spoke\_prd\_subnet\_name | The name for the Spoke PRD subnet. | `string` | `"spoke-prd-subnet-01"` | no |
| spoke\_prd\_vm\_machine\_type | Machine type for Spoke PRD VMs. | `string` | `"e2-medium"` | no |
| spoke\_prd\_vpc\_name | The name for the Spoke PRD VPC network. | `string` | `"spoke-prd-vpc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| hub\_dns\_server\_ips | Details of the hub DNS server VMs, including IP, project, and zone. |
| hub\_utility\_vm\_ips | Details of the hub utility VMs, including IP, project, and zone. |
| spoke\_dev\_cli\_vm\_ips | Details of the spoke development client VMs, including IP, project, and zone. |
| spoke\_prd\_cli\_vm\_ips | Details of the spoke production client VMs, including IP, project, and zone. |

## Disclaimer

This project is intended for demonstration purposes only. It is not intended for use in a production environment.