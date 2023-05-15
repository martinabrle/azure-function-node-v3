terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Root module should specify the maximum provider version
      # The ~> operator is a convenient shorthand for allowing only patch releases within a specific minor release.
      version = "~> 3.55"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.project}-${var.environment}-rg"
  location = var.location
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.project}${var.environment}storage"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_application_insights" "application_insights" {
  name                = "${var.project}-${var.environment}-application-insights"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "Node.JS"
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.project}-${var.environment}-app-service-plan"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "function_app" {
  name                        = "${var.project}-${var.environment}-function-app"
  resource_group_name         = azurerm_resource_group.resource_group.name
  location                    = var.location
  service_plan_id             = azurerm_service_plan.app_service_plan.id
  storage_account_name        = azurerm_storage_account.storage_account.name
  storage_account_access_key  = azurerm_storage_account.storage_account.primary_access_key
  functions_extension_version = "~4"
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.application_insights.instrumentation_key,
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.application_insights.connection_string,
  }
  site_config {
    app_scale_limit          = 1
    elastic_instance_minimum = 0
    application_stack {
      node_version = 18
    }
    cors {
      #TODO:CHANGE THIS!!!!
      allowed_origins = ["*"]
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings["AzureWebJobsDashboard"],
      app_settings["AzureWebJobsStorage"],
      app_settings["WEBSITE_CONTENTAZUREFILECONNECTIONSTRING"],
      app_settings["WEBSITE_CONTENTSHARE"],
      app_settings["WEBSITE_MOUNT_ENABLED"],
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      app_settings["FUNCTIONS_EXTENSION_VERSION"],
      app_settings["FUNCTIONS_WORKER_RUNTIME"],
    ]
  }
}
