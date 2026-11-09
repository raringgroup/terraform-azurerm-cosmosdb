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
##  _variables.tf
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

# DEPRECATED UPSTREAM: azurerm deprecates local_authentication_disabled in favor of
# local_authentication_enabled and removes it in 5.0. The input name is kept for now.
variable "local_authentication_disabled" {
  type        = bool
  description = "Whether key-based authentication is disabled so only Microsoft Entra ID is accepted. Deprecated upstream: azurerm deprecates local_authentication_disabled in favor of local_authentication_enabled and removes it in 5.0"
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
      indexing_policy = optional(object({
        indexing_mode       = optional(string)
        included_paths      = optional(list(string))
        excluded_paths      = optional(list(string))
        spatial_index_paths = optional(list(string))
        composite_indexes = optional(list(list(object({
          path  = string
          order = string
        }))))
      }))
    }))
  }))
  description = "SQL API databases keyed by database name, each with a map of containers keyed by container name. Set max_throughput for autoscale or throughput for manual; leave both null for none. default_ttl null turns TTL off and -1 turns it on with no default expiry. indexing_policy null keeps the Azure default policy; its paths are plain strings (escape quotes, for example \"/\\\"_etag\\\"/?\")"
}

variable "sql_stored_procedures" {
  type = map(object({
    database_name  = string
    container_name = string
    body           = string
  }))
  description = "SQL stored procedures keyed by procedure name; database_name and container_name must match an entry in sql_databases"
}

variable "sql_triggers" {
  type = map(object({
    database_name  = string
    container_name = string
    body           = string
    operation      = string
    type           = string
  }))
  description = "SQL triggers keyed by trigger name; operation is All, Create, Update, Delete or Replace, and type is Pre or Post"
}

variable "sql_functions" {
  type = map(object({
    database_name  = string
    container_name = string
    body           = string
  }))
  description = "SQL user-defined functions keyed by function name"
}

variable "sql_role_definitions" {
  type = map(object({
    assignable_scopes  = optional(set(string))
    role_definition_id = optional(string)
    type               = optional(string)
    permissions = list(object({
      data_actions = set(string)
    }))
  }))
  description = "SQL role definitions keyed by role name; assignable_scopes null scopes the role to the whole account, type is BuiltInRole or CustomRole"
}

variable "sql_role_assignments" {
  type = map(object({
    principal_id        = string
    role_definition_key = optional(string)
    role_definition_id  = optional(string)
    scope               = optional(string)
  }))
  description = "SQL role assignments keyed by a stable name; set exactly one of role_definition_key (a key of sql_role_definitions) or role_definition_id (an existing definition), and scope null grants access on the whole account"
}

variable "sql_dedicated_gateway" {
  type = object({
    instance_count = number
    instance_size  = string
  })
  description = "SQL dedicated gateway; null for none. instance_count is 1 to 5 and instance_size is Cosmos.D4s, Cosmos.D8s or Cosmos.D16s"
}
