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
##  modules/cosmosdb/examples/complete/cosmosdb.tf
##
##  Creates a resource group and a Cosmos DB account with one database and
##  one container.
## ----------------------------------------------------------------------------

## Resource Group
module "resource_group" {
  source  = "../../../resource-group"
  context = module.context.self

  location = var.region
}


## Cosmos DB
module "cosmosdb" {
  source  = "../../"
  context = module.context.self

  automatic_failover_enabled    = false
  free_tier_enabled             = false
  ip_range_filter               = []
  local_authentication_disabled = true
  location                      = module.resource_group.location
  public_network_access_enabled = true
  resource_group_name           = module.resource_group.name
  virtual_network_subnet_ids    = []

  consistency_policy = {
    consistency_level = "Session"
  }

  geo_locations = [
    {
      failover_priority = 0
      location          = module.resource_group.location
    }
  ]

  sql_databases = {
    "orders" = {
      containers = {
        "items" = {
          partition_key_paths = ["/id"]
        }
      }
    }
  }
}
