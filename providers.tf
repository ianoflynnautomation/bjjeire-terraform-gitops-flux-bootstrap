locals {
  kubelogin_aks_server_id = "6dae42f8-4368-4678-94ff-3960e28e3630"

  kubelogin_exec_api_version = "client.authentication.k8s.io/v1beta1"
  kubelogin_exec_command     = "kubelogin"
  kubelogin_exec_args = [
    "get-token",
    "--login", "azurecli",
    "--server-id", local.kubelogin_aks_server_id,
  ]
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_config[0].host
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  exec {
    api_version = local.kubelogin_exec_api_version
    command     = local.kubelogin_exec_command
    args        = local.kubelogin_exec_args
  }
}

provider "helm" {
  kubernetes = {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_config[0].host
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
    exec = {
      api_version = local.kubelogin_exec_api_version
      command     = local.kubelogin_exec_command
      args        = local.kubelogin_exec_args
    }
  }
}

provider "azuread" {}
