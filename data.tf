data "azurerm_client_config" "current" {}

data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault" "kv" {
  name                = var.kv_name
  resource_group_name = var.resource_group_name
}

data "azurerm_user_assigned_identity" "flux_identity" {
  name                = "${var.flux_uami_name_prefix}${var.environment}-${var.location_short_name}"
  resource_group_name = var.resource_group_name
}

data "azurerm_user_assigned_identity" "external_secrets_identity" {
  name                = "${var.external_secrets_uami_name_prefix}${var.environment}-${var.location_short_name}"
  resource_group_name = var.resource_group_name
}

data "azurerm_user_assigned_identity" "api_identity" {
  name                = "${var.api_uami_name_prefix}${var.environment}-${var.location_short_name}"
  resource_group_name = var.resource_group_name
}

data "azurerm_user_assigned_identity" "seeder_identity" {
  name                = "${var.seeder_uami_name_prefix}${var.environment}-${var.location_short_name}"
  resource_group_name = var.resource_group_name
}

data "azurerm_user_assigned_identity" "tests_runner_identity" {
  name                = "${var.tests_runner_uami_name_prefix}${var.environment}-${var.location_short_name}"
  resource_group_name = var.resource_group_name
}

data "azuread_application" "oauth2_proxy" {
  display_name = "${var.oauth2_proxy_app_name_prefix}${var.aks_cluster_name}"
}

data "azuread_application" "bjjeire_api" {
  display_name = "${var.bjjeire_api_app_name_prefix}${var.environment}"
}

data "azurerm_key_vault_secret" "github_app_id" {
  name         = var.kv_secret_name_github_app_id
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "github_app_installation_id" {
  name         = var.kv_secret_name_github_app_installation_id
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "github_app_private_key" {
  name         = var.kv_secret_name_github_app_private_key
  key_vault_id = data.azurerm_key_vault.kv.id
}
