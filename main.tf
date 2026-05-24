locals {
  kubernetes_secret_type_opaque = "Opaque"
}

resource "kubernetes_namespace_v1" "flux_system" {
  metadata {
    name = var.flux_namespace
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_secret_v1" "flux_github_app" {
  metadata {
    name      = var.flux_github_app_secret_name
    namespace = kubernetes_namespace_v1.flux_system.metadata[0].name
  }

  data = {
    githubAppID             = data.azurerm_key_vault_secret.github_app_id.value
    githubAppInstallationID = data.azurerm_key_vault_secret.github_app_installation_id.value
    githubAppPrivateKey     = data.azurerm_key_vault_secret.github_app_private_key.value
  }

  type = local.kubernetes_secret_type_opaque
}

resource "kubernetes_config_map_v1" "cluster_config" {
  metadata {
    name      = var.cluster_config_configmap_name
    namespace = kubernetes_namespace_v1.flux_system.metadata[0].name
  }

  data = {
    CLUSTER_REGION             = data.azurerm_kubernetes_cluster.aks.location
    CLUSTER_ID                 = data.azurerm_kubernetes_cluster.aks.name
    RESOURCE_GROUP             = data.azurerm_kubernetes_cluster.aks.resource_group_name
    CLUSTER_DOMAIN             = var.cluster_domain
    KEY_VAULT_NAME             = data.azurerm_key_vault.kv.name
    TENANT_ID                  = data.azurerm_client_config.current.tenant_id
    AZURE_SUBSCRIPTION_ID      = data.azurerm_client_config.current.subscription_id
    PRIVATE_EMAIL              = var.private_email
    OAUTH2_PROXY_CLIENT_ID     = data.azuread_application.oauth2_proxy.client_id
    OAUTH2_PROXY_ALLOWED_GROUP = var.oauth2_proxy_allowed_group_id
  }
}

resource "kubernetes_config_map_v1" "workload_identity_config" {
  metadata {
    name      = var.workload_identity_configmap_name
    namespace = kubernetes_namespace_v1.flux_system.metadata[0].name
  }

  data = {
    FLUX_CLIENT_ID             = data.azurerm_user_assigned_identity.flux_identity.client_id
    EXTERNAL_SECRETS_CLIENT_ID = data.azurerm_user_assigned_identity.external_secrets_identity.client_id
  }
}

resource "helm_release" "flux_operator" {
  name             = var.flux_operator_release_name
  namespace        = kubernetes_namespace_v1.flux_system.metadata[0].name
  repository       = var.flux_chart_repository
  chart            = var.flux_operator_chart_name
  create_namespace = false
  wait             = var.flux_helm_wait
  wait_for_jobs    = var.flux_helm_wait_for_jobs
  timeout          = var.flux_helm_timeout_seconds

  depends_on = [
    kubernetes_namespace_v1.flux_system
  ]
}

resource "helm_release" "flux_instance" {
  name             = var.flux_instance_release_name
  namespace        = kubernetes_namespace_v1.flux_system.metadata[0].name
  repository       = var.flux_chart_repository
  chart            = var.flux_instance_chart_name
  create_namespace = false
  wait             = var.flux_helm_wait
  wait_for_jobs    = var.flux_helm_wait_for_jobs
  timeout          = var.flux_helm_timeout_seconds

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
    kubernetes_secret_v1.flux_github_app
  ]
}
