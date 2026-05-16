
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
  name                = "uami-flux-${var.environment}-${var.location_short_name}"
  resource_group_name = var.resource_group_name
}

data "azurerm_user_assigned_identity" "external_secrets_identity" {
  name                = "uami-extsecrets-${var.environment}-${var.location_short_name}"
  resource_group_name = var.resource_group_name
}

data "azuread_application" "oauth2_proxy" {
  display_name = "oauth2-proxy-${var.aks_cluster_name}"
}

data "azurerm_key_vault_secret" "github_app_id" {
  name         = "github-app-id"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "github_app_installation_id" {
  name         = "github-app-installation-id"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "github_app_private_key" {
  name         = "github-app-private-key"
  key_vault_id = data.azurerm_key_vault.kv.id
}