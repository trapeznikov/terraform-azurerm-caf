terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.24.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 0.11.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.2.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 1.2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 2.2.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~>0.4.3"
    }
  }
  required_version = ">= 0.13"
}


provider "azurerm" {
  features {}
}


resource "random_string" "prefix" {
  length  = 4
  special = false
  upper   = false
  number  = false
}

resource "random_string" "alpha1" {
  length  = 1
  special = false
  upper   = false
  number  = false
}

locals {
  landingzone_tag = {
    landingzone = var.launchpad_mode
  }
  tags = merge(local.landingzone_tag, { "level" = var.level }, { "environment" = var.environment }, { "rover_version" = var.rover_version }, var.tags)

  prefix = var.prefix == null ? random_string.prefix.result : var.prefix

  global_settings = {
    prefix             = local.prefix
    prefix_with_hyphen = local.prefix == "" ? "" : "${local.prefix}-"
    prefix_start_alpha = local.prefix == "" ? "" : "${random_string.alpha1.result}${local.prefix}"
    convention         = var.convention
    default_region     = var.default_region
    environment        = var.environment
    regions            = var.regions
    max_length         = var.max_length
  }

  tfstates = {
    launchpad = {
      storage_account_name = var.tfstate_storage_account_name
      container_name       = var.tfstate_container_name
      resource_group_name  = var.tfstate_resource_group_name
      key                  = var.tfstate_key
      level                = var.level
      tenant_id            = data.azurerm_client_config.current.tenant_id
      subscription_id      = data.azurerm_client_config.current.subscription_id
    }
  }

}

data "azurerm_client_config" "current" {}