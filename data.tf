

data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault" "kv" {
  name                = var.kv_name
  resource_group_name = var.resource_group_name
}

data "azurerm_user_assigned_identity" "flux_identity" {
  name                = "${var.aks_cluster_name}-flux-identity"
  resource_group_name = var.resource_group_name
}

data "azurerm_client_config" "current" {}
