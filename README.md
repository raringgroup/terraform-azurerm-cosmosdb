# cosmosdb

Creates an Azure Cosmos DB account (SQL API, `GlobalDocumentDB`) with its SQL databases and containers, and optionally stored procedures, triggers, user-defined functions, role definitions, role assignments and a dedicated gateway. Everything is named through the `null-context` module.

## Requirements

| Name | Version |
|------|---------|
| terraform | `>= 1.3.0` |
| azurerm | `>= 4.0.0, < 5.0.0` |

## Module Priority

No SevenPico, SevenPicoForks or CloudPosse module exists for Azure Cosmos DB, so the module uses `azurerm_cosmosdb_*` resources directly. The account name is limited to 44 characters, the Azure maximum. Database, container, procedure, trigger, function and role names are the map keys you supply. `_context.tf` declares the root context; it and the child contexts use `git::https://github.com/raringgroup/terraform-null-context.git?ref=v0.1.0`.

## Naming

The account name is built by `null-context` from the context inputs plus the type token `cdb`. These inputs produce `cdb-upsis-dev-ehssync`:

```hcl
inputs = {
  namespace   = "upsis"
  environment = "dev"
  name        = "ehssync"
  label_order = ["attributes", "namespace", "environment", "name"]
}
```

## Inputs

All inputs are required (no defaults); use `null`, `{}` or `[]` for anything you do not need. Context inputs (`enabled`, `namespace`, `environment`, `stage`, `name`, `attributes`, `tags`, ...) are declared in `_context.tf`.

| Name | Type | Description |
|------|------|-------------|
| resource_group_name | `string` | Resource group that holds the account |
| location | `string` | Azure region where the account is created |
| automatic_failover_enabled | `bool` | Automatic failover to a secondary region |
| free_tier_enabled | `bool` | Free tier (one per subscription) |
| local_authentication_disabled | `bool` | Disable key-based authentication so only Microsoft Entra ID is accepted. Deprecated upstream in favor of `local_authentication_enabled`, which azurerm removes in 5.0 |
| public_network_access_enabled | `bool` | Accept traffic from the public network |
| ip_range_filter | `list(string)` | Allowed IP addresses or CIDR ranges |
| virtual_network_subnet_ids | `list(string)` | Allowed subnet IDs (need the `Microsoft.AzureCosmosDB` service endpoint) |
| consistency_policy | `object` | `consistency_level`; `max_interval_in_seconds` and `max_staleness_prefix` only for BoundedStaleness |
| geo_locations | `list(object)` | `location`, `failover_priority`, `zone_redundant`; exactly one entry with priority 0 |
| sql_databases | `map(object)` | Databases keyed by name with optional `throughput` or `max_throughput` (autoscale) and a `containers` map. Per container: `partition_key_paths`, `partition_key_version`, `default_ttl`, `throughput`, `max_throughput` and `indexing_policy` |
| sql_stored_procedures | `map(object)` | Keyed by procedure name: `database_name`, `container_name`, `body` |
| sql_triggers | `map(object)` | Keyed by trigger name: `database_name`, `container_name`, `body`, `operation` (`All`, `Create`, `Update`, `Delete`, `Replace`), `type` (`Pre`, `Post`) |
| sql_functions | `map(object)` | Keyed by function name: `database_name`, `container_name`, `body` |
| sql_role_definitions | `map(object)` | Keyed by role name: `permissions` (list of `data_actions`), `assignable_scopes` (null scopes the role to the account), `role_definition_id`, `type` (`BuiltInRole`, `CustomRole`) |
| sql_role_assignments | `map(object)` | Keyed by name: `principal_id`, exactly one of `role_definition_key` (a key of `sql_role_definitions`) or `role_definition_id`, and `scope` (null grants access on the account) |
| sql_dedicated_gateway | `object` | `instance_count` (1 to 5) and `instance_size` (`Cosmos.D4s`, `Cosmos.D8s`, `Cosmos.D16s`); `null` for none |

### Containers

- `default_ttl`: `null` turns TTL off, `-1` turns it on with no default expiry (what the workload uses), any other number is a default expiry in seconds.
- `indexing_policy`: `null` keeps the Azure default policy. Otherwise set `indexing_mode` (`consistent` or `none`), `included_paths`, `excluded_paths`, `spatial_index_paths` (all plain strings) and `composite_indexes` (a list of lists of `{ path, order }`). Azure requires `/*` in either the included or the excluded paths. Escape quotes in paths, for example `"/\"_etag\"/?"`.
- Not supported by the azurerm provider, and therefore not by this module: computed properties and full-text policies. A container geospatial configuration (Geography or Geometry) is not exposed either; containers get the Azure default, Geography, which is what the workload uses.

## Outputs

| Name | Description |
|------|-------------|
| id | Account ID (null when disabled) |
| name | Account name (null when disabled) |
| endpoint | Account endpoint (null when disabled) |
| sql_database_ids | Map of database name to ID |
| sql_container_ids | Map of `database/container` to ID |
| sql_stored_procedure_ids | Map of procedure name to ID |
| sql_trigger_ids | Map of trigger name to ID |
| sql_function_ids | Map of function name to ID |
| sql_role_definition_ids | Map of role name to ID |
| sql_role_assignment_ids | Map of role assignment key to ID |
| sql_dedicated_gateway_id | Dedicated gateway ID (null when there is none or the module is disabled) |

Account keys and connection strings are deliberately not output. Use Microsoft Entra ID with role assignments.

## Usage

```hcl
terraform {
  source = "git::https://github.com/raringgroup/terraform-azurerm-cosmosdb.git?ref=develop"
}

inputs = {
  enabled     = true
  namespace   = "<namespace>"
  environment = "<environment>"
  name        = "<name>"
  label_order = ["attributes", "namespace", "environment", "name"]

  automatic_failover_enabled    = false
  free_tier_enabled             = false
  ip_range_filter               = []
  local_authentication_disabled = true
  location                      = "<azure-region>"
  public_network_access_enabled = false
  resource_group_name           = "<resource-group>"
  virtual_network_subnet_ids    = []

  consistency_policy = {
    consistency_level = "Session"
  }

  geo_locations = [
    {
      location          = "<azure-region>"
      failover_priority = 0
    }
  ]

  sql_databases = {
    "<database>" = {
      containers = {
        "<container>" = {
          partition_key_paths = ["/<partition-key>"]
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
```

## License

Apache License 2.0. Copyright 2026 Raring Group LLC.
