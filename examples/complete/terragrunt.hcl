# -----------------------------------------------------------------------------
# Copyright 2026 Raring Group LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# -----------------------------------------------------------------------------

# TERRAGRUNT — COSMOSDB EXAMPLE
# ------------------------------------------------------------------------------
# modules/cosmosdb/examples/complete/terragrunt.hcl
#
# Deploys the cosmosdb example to Azure. Generates the azurerm provider and
# backend and passes the standard context inputs.
#
# Module: modules/cosmosdb
# ------------------------------------------------------------------------------

locals {
  subscription_id = get_env("ARM_SUBSCRIPTION_ID")
  location        = get_env("AZURE_LOCATION")

  namespace   = "rg"
  tenant      = "Raring"
  project     = "cosmosdb"
  environment = ""
  stage       = basename(get_terragrunt_dir())

  tags                = { Source = "Managed by Terraform" }
  regex_replace_chars = "/[^-a-zA-Z0-9]/"
  delimiter           = "-"
  id_length_limit     = 0
  label_key_case      = "title"
  label_value_case    = "lower"
  label_order         = ["namespace", "project", "environment", "stage", "name", "attributes"]
}


generate "provider" {
  path      = "generated-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}
EOF
}


remote_state {
  backend      = "azurerm"
  disable_init = true

  config = {
    container_name       = get_env("TF_STATE_CONTAINER")
    key                  = "${local.subscription_id}/${local.project}/${local.stage}/terraform.tfstate"
    resource_group_name  = get_env("TF_STATE_RESOURCE_GROUP")
    storage_account_name = get_env("TF_STATE_STORAGE_ACCOUNT")
    use_azuread_auth     = true
  }

  generate = {
    path      = "generated-backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}


inputs = {
  # Standard Context
  delimiter           = local.delimiter
  environment         = local.environment
  id_length_limit     = local.id_length_limit
  label_key_case      = local.label_key_case
  label_order         = local.label_order
  label_value_case    = local.label_value_case
  namespace           = local.namespace
  project             = local.project
  regex_replace_chars = local.regex_replace_chars
  region              = local.location
  stage               = local.stage
  tags                = local.tags
  tenant              = local.tenant
}
