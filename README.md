# cosmosdb

Creates an Azure Cosmos DB account (SQL API, `GlobalDocumentDB`) with its SQL databases and containers, named through the SevenPico context module.

## Requirements

| Name | Version |
|------|---------|
| terraform | `>= 1.3.0` |
| azurerm | `>= 4.0.0, < 5.0.0` |

## Module Priority

No SevenPico, SevenPicoForks or CloudPosse module exists for Azure Cosmos DB, so the module uses `azurerm_cosmosdb_*` resources directly. The account name comes from the context module (limited to 44 characters, the Azure maximum). Database and container names are the map keys you supply. Naming and the enabled flag come from the context module. `_context.tf` declares the root context (`SevenPico/context/null` `2.0.0`); child contexts use the local `../null-context` module.

## Inputs

All inputs are required (no defaults). Context inputs (`enabled`, `namespace`, `environment`, `stage`, `name`, `attributes`, `tags`, ...) are declared in `_context.tf`.

| Name | Type | Description |
|------|------|-------------|
| resource_group_name | `string` | Resource group that holds the account |
| location | `string` | Azure region where the account is created |
| automatic_failover_enabled | `bool` | Automatic failover to a secondary region |
| free_tier_enabled | `bool` | Free tier (one per subscription) |
| local_authentication_disabled | `bool` | Disable key-based authentication |
| public_network_access_enabled | `bool` | Accept traffic from the public network |
| ip_range_filter | `list(string)` | Allowed IP addresses or CIDR ranges |
| virtual_network_subnet_ids | `list(string)` | Allowed subnet IDs (need the `Microsoft.AzureCosmosDB` service endpoint) |
| consistency_policy | `object` | `consistency_level`; `max_interval_in_seconds` and `max_staleness_prefix` only for BoundedStaleness |
| geo_locations | `list(object)` | `location`, `failover_priority`, `zone_redundant`; exactly one entry with priority 0 |
| sql_databases | `map(object)` | Databases keyed by name with optional `throughput` or `max_throughput` (autoscale) and a `containers` map (`partition_key_paths`, `partition_key_version`, `default_ttl`, `throughput`, `max_throughput`) |

## Outputs

| Name | Description |
|------|-------------|
| id | Account ID (null when disabled) |
| name | Account name (null when disabled) |
| endpoint | Account endpoint (null when disabled) |
| sql_database_ids | Map of database name to ID |
| sql_container_ids | Map of `database/container` to ID |

Account keys and connection strings are deliberately not output. Use Microsoft Entra ID with role assignments, or read keys from the account where required.

## Usage

```hcl
terraform {
  source = "git::<repo-url>//modules/cosmosdb?ref=cosmosdb-v<version>"
}

dependency "resource_group" {
  config_path = "../resource-group"
}

inputs = {
  enabled     = true
  namespace   = "<namespace>"
  environment = "<environment>"
  stage       = "<stage>"
  name        = "<name>"

  automatic_failover_enabled    = false
  free_tier_enabled             = false
  ip_range_filter               = []
  local_authentication_disabled = true
  location                      = dependency.resource_group.outputs.location
  public_network_access_enabled = false
  resource_group_name           = dependency.resource_group.outputs.name
  virtual_network_subnet_ids    = []

  consistency_policy = {
    consistency_level = "Session"
  }

  geo_locations = [
    {
      location          = dependency.resource_group.outputs.location
      failover_priority = 0
    }
  ]

  sql_databases = {
    "<database>" = {
      containers = {
        "<container>" = {
          partition_key_paths = ["/<partition-key>"]
        }
      }
    }
  }
}
```

## License

Apache License 2.0. Copyright 2026 Raring Group LLC.
