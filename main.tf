
locals {
  flux_namespace = "flux-system"
}


resource "kubernetes_namespace_v1" "flux_system" {
  metadata {
    name = local.flux_namespace
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}


resource "kubernetes_secret_v1" "flux_github_token" {
  metadata {
    name      = "flux-system"
    namespace = kubernetes_namespace_v1.flux_system.metadata[0].name
  }

  data = {
    username = "git"
    password = var.github_token
  }

  type = "Opaque"
}

resource "kubernetes_config_map_v1" "cluster_config" {
  metadata {
    name      = "cluster-config"
    namespace = kubernetes_namespace_v1.flux_system.metadata[0].name
  }

  data = {
    CLUSTER_REGION = data.azurerm_kubernetes_cluster.aks.location
    CLUSTER_ID     = data.azurerm_kubernetes_cluster.aks.name
    RESOURCE_GROUP = data.azurerm_kubernetes_cluster.aks.resource_group_name
    CLUSTER_DOMAIN = var.cluster_domain
    KEY_VAULT_NAME = data.azurerm_key_vault.kv.name
    TENANT_ID      = data.azurerm_client_config.current.tenant_id
  }
}

resource "kubernetes_config_map_v1" "workload_identity_config" {
  metadata {
    name      = "workload-identity-config"
    namespace = kubernetes_namespace_v1.flux_system.metadata[0].name
  }

  data = {
    WORKLOAD_IDENTITY_CLIENT_ID = data.azurerm_user_assigned_identity.flux_identity.client_id
  }
}

resource "helm_release" "flux_operator" {
  name             = "flux-operator"
  namespace        = kubernetes_namespace_v1.flux_system.metadata[0].name
  repository       = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart            = "flux-operator"
  create_namespace = false
  wait             = true
  wait_for_jobs    = true
  timeout          = 600

    depends_on = [
    kubernetes_namespace_v1.flux_system
  ]
}

resource "helm_release" "flux_instance" {
  name             = "flux"
  namespace        = kubernetes_namespace_v1.flux_system.metadata[0].name
  repository       = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart            = "flux-instance"
  create_namespace = false
  wait             = true
  wait_for_jobs    = true
  timeout          = 600

  values = [
    templatefile("${path.module}/templates/flux-instance-values.yaml.tpl", {
      client_id      = data.azurerm_user_assigned_identity.flux_identity.client_id
      tenant_id      = data.azurerm_client_config.current.tenant_id
      flux_version   = var.flux_version
      flux_registry  = var.flux_registry
      cluster_type   = var.cluster_type
      cluster_size   = var.cluster_size
      cluster_domain = var.cluster_domain
      sync_kind      = var.sync_kind
      sync_provider  = var.sync_provider
      git_url        = var.git_url
      git_ref        = var.git_ref
      git_path       = var.git_path
    })
  ]
  depends_on = [
    helm_release.flux_operator,
    kubernetes_secret_v1.flux_github_token
  ]
}
