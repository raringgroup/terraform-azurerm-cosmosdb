# tflint-ignore-file: terraform_unused_declarations

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
##  modules/cosmosdb/_data.tf
##
##  Azure caller identity and subscription lookups, exposed as locals.
## ----------------------------------------------------------------------------

data "azurerm_client_config" "current" {
  count = module.context.enabled ? 1 : 0
}

data "azurerm_subscription" "current" {
  count = module.context.enabled ? 1 : 0
}

locals {
  caller_object_id   = try(data.azurerm_client_config.current[0].object_id, "")
  subscription_id    = try(data.azurerm_subscription.current[0].subscription_id, "")
  subscription_scope = try(data.azurerm_subscription.current[0].id, "")
  tenant_id          = try(data.azurerm_client_config.current[0].tenant_id, "")
}
