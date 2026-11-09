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
##  modules/cosmosdb/_locals.tf
##
##  Flattens the nested database and container map for for_each.
## ----------------------------------------------------------------------------

locals {
  sql_containers = merge([
    for db_name, db in var.sql_databases : {
      for container_name, container in db.containers :
      "${db_name}/${container_name}" => merge(container, {
        container_name = container_name
        database_name  = db_name
      })
    }
  ]...)
}
