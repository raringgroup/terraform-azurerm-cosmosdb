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
##  _outputs.tf
##
##  Output values for the Cosmos DB module. Account keys are never output.
## ----------------------------------------------------------------------------

output "id" {
  description = "Cosmos DB account ID (null when disabled)"
  value       = try(azurerm_cosmosdb_account.this[0].id, null)
}

output "name" {
  description = "Cosmos DB account name (null when disabled)"
  value       = try(azurerm_cosmosdb_account.this[0].name, null)
}

output "endpoint" {
  description = "Cosmos DB account endpoint (null when disabled)"
  value       = try(azurerm_cosmosdb_account.this[0].endpoint, null)
}

output "sql_database_ids" {
  description = "Map of database name to SQL database ID"
  value       = { for k, v in azurerm_cosmosdb_sql_database.this : k => v.id }
}

output "sql_container_ids" {
  description = "Map of database/container name to SQL container ID"
  value       = { for k, v in azurerm_cosmosdb_sql_container.this : k => v.id }
}

output "sql_stored_procedure_ids" {
  description = "Map of stored procedure name to ID"
  value       = { for k, v in azurerm_cosmosdb_sql_stored_procedure.this : k => v.id }
}

output "sql_trigger_ids" {
  description = "Map of trigger name to ID"
  value       = { for k, v in azurerm_cosmosdb_sql_trigger.this : k => v.id }
}

output "sql_function_ids" {
  description = "Map of user-defined function name to ID"
  value       = { for k, v in azurerm_cosmosdb_sql_function.this : k => v.id }
}

output "sql_role_definition_ids" {
  description = "Map of role definition name to ID"
  value       = { for k, v in azurerm_cosmosdb_sql_role_definition.this : k => v.id }
}

output "sql_role_assignment_ids" {
  description = "Map of role assignment key to ID"
  value       = { for k, v in azurerm_cosmosdb_sql_role_assignment.this : k => v.id }
}

output "sql_dedicated_gateway_id" {
  description = "SQL dedicated gateway ID (null when there is none or the module is disabled)"
  value       = try(azurerm_cosmosdb_sql_dedicated_gateway.this[0].id, null)
}
