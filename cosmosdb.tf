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
##  cosmosdb.tf
##
##  Cosmos DB account (SQL API) with its databases, containers, stored procedures, triggers, functions, role definitions and role assignments, and an optional dedicated gateway.
## ----------------------------------------------------------------------------

## Cosmos DB Context
module "cosmosdb_context" {
  source  = "git::https://github.com/raringgroup/terraform-null-context.git?ref=v0.1.0"
  context = module.context.self

  attributes      = ["cdb"]
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

  dynamic "indexing_policy" {
    for_each = each.value.indexing_policy == null ? [] : [each.value.indexing_policy]

    content {
      indexing_mode = indexing_policy.value.indexing_mode

      dynamic "composite_index" {
        for_each = indexing_policy.value.composite_indexes == null ? [] : indexing_policy.value.composite_indexes

        content {
          dynamic "index" {
            for_each = composite_index.value

            content {
              order = index.value.order
              path  = index.value.path
            }
          }
        }
      }

      dynamic "excluded_path" {
        for_each = toset(indexing_policy.value.excluded_paths == null ? [] : indexing_policy.value.excluded_paths)

        content {
          path = excluded_path.value
        }
      }

      dynamic "included_path" {
        for_each = toset(indexing_policy.value.included_paths == null ? [] : indexing_policy.value.included_paths)

        content {
          path = included_path.value
        }
      }

      dynamic "spatial_index" {
        for_each = toset(indexing_policy.value.spatial_index_paths == null ? [] : indexing_policy.value.spatial_index_paths)

        content {
          path = spatial_index.value
        }
      }
    }
  }
}


## SQL Stored Procedures
resource "azurerm_cosmosdb_sql_stored_procedure" "this" {
  for_each = module.cosmosdb_context.enabled ? var.sql_stored_procedures : {}

  account_name        = azurerm_cosmosdb_account.this[0].name
  body                = each.value.body
  container_name      = azurerm_cosmosdb_sql_container.this["${each.value.database_name}/${each.value.container_name}"].name
  database_name       = azurerm_cosmosdb_sql_database.this[each.value.database_name].name
  name                = each.key
  resource_group_name = var.resource_group_name
}


## SQL Triggers
resource "azurerm_cosmosdb_sql_trigger" "this" {
  for_each = module.cosmosdb_context.enabled ? var.sql_triggers : {}

  body         = each.value.body
  container_id = azurerm_cosmosdb_sql_container.this["${each.value.database_name}/${each.value.container_name}"].id
  name         = each.key
  operation    = each.value.operation
  type         = each.value.type
}


## SQL User Defined Functions
resource "azurerm_cosmosdb_sql_function" "this" {
  for_each = module.cosmosdb_context.enabled ? var.sql_functions : {}

  body         = each.value.body
  container_id = azurerm_cosmosdb_sql_container.this["${each.value.database_name}/${each.value.container_name}"].id
  name         = each.key
}


## SQL Role Definitions
resource "azurerm_cosmosdb_sql_role_definition" "this" {
  for_each = module.cosmosdb_context.enabled ? var.sql_role_definitions : {}

  account_name        = azurerm_cosmosdb_account.this[0].name
  assignable_scopes   = each.value.assignable_scopes == null ? toset([azurerm_cosmosdb_account.this[0].id]) : each.value.assignable_scopes
  name                = each.key
  resource_group_name = var.resource_group_name
  role_definition_id  = each.value.role_definition_id
  type                = each.value.type

  dynamic "permissions" {
    for_each = each.value.permissions

    content {
      data_actions = permissions.value.data_actions
    }
  }
}


## SQL Role Assignments
resource "azurerm_cosmosdb_sql_role_assignment" "this" {
  for_each = module.cosmosdb_context.enabled ? var.sql_role_assignments : {}

  account_name        = azurerm_cosmosdb_account.this[0].name
  principal_id        = each.value.principal_id
  resource_group_name = var.resource_group_name
  role_definition_id  = each.value.role_definition_key == null ? each.value.role_definition_id : azurerm_cosmosdb_sql_role_definition.this[each.value.role_definition_key].id
  scope               = each.value.scope == null ? azurerm_cosmosdb_account.this[0].id : each.value.scope

  lifecycle {
    precondition {
      condition     = (each.value.role_definition_key == null) != (each.value.role_definition_id == null)
      error_message = "Set exactly one of role_definition_key and role_definition_id."
    }
  }
}


## SQL Dedicated Gateway
resource "azurerm_cosmosdb_sql_dedicated_gateway" "this" {
  count = module.cosmosdb_context.enabled && var.sql_dedicated_gateway != null ? 1 : 0

  cosmosdb_account_id = azurerm_cosmosdb_account.this[0].id
  instance_count      = var.sql_dedicated_gateway.instance_count
  instance_size       = var.sql_dedicated_gateway.instance_size
}
