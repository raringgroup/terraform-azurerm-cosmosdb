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
##  modules/cosmosdb/examples/complete/_outputs.tf
##
##  Outputs of the example.
## ----------------------------------------------------------------------------

output "id" {
  value = module.cosmosdb.id
}

output "name" {
  value = module.cosmosdb.name
}

output "endpoint" {
  value = module.cosmosdb.endpoint
}

output "sql_database_ids" {
  value = module.cosmosdb.sql_database_ids
}

output "sql_container_ids" {
  value = module.cosmosdb.sql_container_ids
}
