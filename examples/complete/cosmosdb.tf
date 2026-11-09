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
##  examples/complete/cosmosdb.tf
##
##  Creates a resource group and a Cosmos DB account with one database and
##  two containers, one of them with an explicit indexing policy.
## ----------------------------------------------------------------------------

## Resource Group
resource "azurerm_resource_group" "this" {
  location = var.region
  name     = "${module.context.id}-rg"
  tags     = module.context.tags
}


## Cosmos DB
module "cosmosdb" {
  source  = "../../"
  context = module.context.self

  automatic_failover_enabled    = false
  free_tier_enabled             = false
  ip_range_filter               = []
  local_authentication_disabled = true
  location                      = azurerm_resource_group.this.location
  public_network_access_enabled = true
  resource_group_name           = azurerm_resource_group.this.name
  virtual_network_subnet_ids    = []

  consistency_policy = {
    consistency_level = "Session"
  }

  geo_locations = [
    {
      failover_priority = 0
      location          = azurerm_resource_group.this.location
    }
  ]

  sql_databases = {
    "orders" = {
      containers = {
        "items" = {
          partition_key_paths = ["/id"]
        }
        "entities" = {
          partition_key_paths = ["/entityType"]
          default_ttl         = -1

          indexing_policy = {
            indexing_mode  = "consistent"
            included_paths = ["/*"]
            excluded_paths = ["/\"_etag\"/?"]
          }
        }
      }
    }
  }

  sql_dedicated_gateway = null
  sql_functions         = {}
  sql_role_assignments  = {}
  sql_role_definitions  = {}
  sql_stored_procedures = {}
  sql_triggers          = {}
}
