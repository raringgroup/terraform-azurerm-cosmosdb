## ----------------------------------------------------------------------------
## Copyright 2026 Raring Group LLC
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
## ----------------------------------------------------------------------------
##
##  modules/cosmosdb/_variables.tf
##
##  Input variables for the Cosmos DB (SQL API) module.
## ----------------------------------------------------------------------------

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group that holds the Cosmos DB account"
}

variable "location" {
  type        = string
  description = "Azure region where the Cosmos DB account is created"
}

variable "automatic_failover_enabled" {
  type        = bool
  description = "Whether automatic failover to a secondary region is enabled"
}

variable "free_tier_enabled" {
  type        = bool
  description = "Whether the free tier is enabled (one per subscription)"
}

variable "local_authentication_disabled" {
  type        = bool
  description = "Whether key-based authentication is disabled so only Microsoft Entra ID is accepted"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether the account accepts traffic from the public network"
}

variable "ip_range_filter" {
  type        = list(string)
  description = "IP addresses or CIDR ranges allowed to reach the account"
}

variable "virtual_network_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs allowed to reach the account (subnets need the Microsoft.AzureCosmosDB service endpoint)"
}

variable "consistency_policy" {
  type = object({
    consistency_level       = string
    max_interval_in_seconds = optional(number)
    max_staleness_prefix    = optional(number)
  })
  description = "Consistency level; the two max_* values apply only to BoundedStaleness"
}

variable "geo_locations" {
  type = list(object({
    location          = string
    failover_priority = number
    zone_redundant    = optional(bool)
  }))
  description = "Regions the account is replicated to; exactly one entry must have failover_priority 0"
}

variable "sql_databases" {
  type = map(object({
    throughput     = optional(number)
    max_throughput = optional(number)
    containers = map(object({
      partition_key_paths   = list(string)
      partition_key_version = optional(number)
      default_ttl           = optional(number)
      throughput            = optional(number)
      max_throughput        = optional(number)
    }))
  }))
  description = "SQL API databases keyed by database name, each with a map of containers keyed by container name. Set max_throughput for autoscale or throughput for manual; leave both null for none"
}
