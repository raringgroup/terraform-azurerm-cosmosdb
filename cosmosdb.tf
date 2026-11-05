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
##  modules/cosmosdb/cosmosdb.tf
##
##  Cosmos DB account (SQL API) with its databases and containers.
## ----------------------------------------------------------------------------

## Cosmos DB Context
module "cosmosdb_context" {
  source  = "../null-context"
  context = module.context.self

  attributes      = ["cosmos"]
  id_length_limit = 44
}


## Cosmos DB Account
resource "azurerm_cosmosdb_account" "this" {
  count = module.cosmosdb_context.enabled ? 1 : 0

  automatic_failover_enabled        = var.automatic_failover_enabled
  free_tier_enabled                 = var.free_tier_enabled
  ip_range_filter                   = toset(var.ip_range_filter)
  is_virtual_network_filter_enabled = length(var.virtual_network_subnet_ids) > 0
  kind                              = "GlobalDocumentDB"
  local_authentication_disabled     = var.local_authentication_disabled
  location                          = var.location
  name                              = module.cosmosdb_context.id
  offer_type                        = "Standard"
  public_network_access_enabled     = var.public_network_access_enabled
  resource_group_name               = var.resource_group_name
  tags                              = module.cosmosdb_context.tags

  consistency_policy {
    consistency_level       = var.consistency_policy.consistency_level
    max_interval_in_seconds = var.consistency_policy.max_interval_in_seconds
    max_staleness_prefix    = var.consistency_policy.max_staleness_prefix
  }

  dynamic "geo_location" {
    for_each = var.geo_locations

    content {
      failover_priority = geo_location.value.failover_priority
      location          = geo_location.value.location
      zone_redundant    = geo_location.value.zone_redundant
    }
  }

  dynamic "virtual_network_rule" {
    for_each = toset(var.virtual_network_subnet_ids)

    content {
      id = virtual_network_rule.value
    }
  }
}


## SQL Databases
resource "azurerm_cosmosdb_sql_database" "this" {
  for_each = module.cosmosdb_context.enabled ? var.sql_databases : {}

  account_name        = azurerm_cosmosdb_account.this[0].name
  name                = each.key
  resource_group_name = var.resource_group_name
  throughput          = each.value.max_throughput == null ? each.value.throughput : null

  dynamic "autoscale_settings" {
    for_each = each.value.max_throughput == null ? [] : [each.value.max_throughput]

    content {
      max_throughput = autoscale_settings.value
    }
  }
}


## SQL Containers
resource "azurerm_cosmosdb_sql_container" "this" {
  for_each = module.cosmosdb_context.enabled ? local.sql_containers : {}

  account_name          = azurerm_cosmosdb_account.this[0].name
  database_name         = azurerm_cosmosdb_sql_database.this[each.value.database_name].name
  default_ttl           = each.value.default_ttl
  name                  = each.value.container_name
  partition_key_paths   = each.value.partition_key_paths
  partition_key_version = each.value.partition_key_version
  resource_group_name   = var.resource_group_name
  throughput            = each.value.max_throughput == null ? each.value.throughput : null

  dynamic "autoscale_settings" {
    for_each = each.value.max_throughput == null ? [] : [each.value.max_throughput]

    content {
      max_throughput = autoscale_settings.value
    }
  }
}
