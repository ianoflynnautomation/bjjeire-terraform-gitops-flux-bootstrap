
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


