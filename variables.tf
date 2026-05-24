variable "subscription_id" {
  type        = string
  description = "Subscription that owns the AKS cluster and Key Vault."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group containing the AKS cluster, Key Vault, and workload-identity UAMIs."
}

variable "aks_cluster_name" {
  type        = string
  default     = null
  description = "Name of the AKS cluster to bootstrap Flux on. Also used to derive the oauth2-proxy app registration display name."
}

variable "kv_name" {
  type        = string
  description = "Key Vault name holding the Flux GitHub App credentials (3-24 alphanumeric/dash characters, starting with a letter)."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.kv_name))
    error_message = "kv_name must be 3-24 characters and may only contain letters, numbers and dashes."
  }
  validation {
    condition     = !can(regex("--", var.kv_name))
    error_message = "kv_name must not contain two consecutive dashes."
  }
  validation {
    condition     = can(regex("^[a-zA-Z]", var.kv_name))
    error_message = "kv_name must start with a letter."
  }
  validation {
    condition     = can(regex("[a-zA-Z0-9]$", var.kv_name))
    error_message = "kv_name must end with a letter or number."
  }
}

variable "environment" {
  type        = string
  description = "Environment short name (dev, staging, prod). Used in UAMI name composition."
}

variable "location_short_name" {
  type        = string
  default     = "swn"
  description = "Region short name used in UAMI name composition."
  nullable    = false
}

variable "private_email" {
  type        = string
  description = "Operator contact email surfaced to the cluster via the cluster-config ConfigMap."
  sensitive   = true
}

variable "cluster_domain" {
  type        = string
  default     = "cluster.local"
  description = "DNS suffix exposed to workloads via the cluster-config ConfigMap."
}

variable "oauth2_proxy_allowed_group_id" {
  type        = string
  description = "Entra ID security group object ID allowed past oauth2-proxy. Consumed by the cluster-config ConfigMap."
}

variable "flux_uami_name_prefix" {
  type        = string
  default     = "uami-flux-"
  description = "Prefix of the Flux UAMI. Composed as <prefix><environment>-<location_short_name>."
  nullable    = false
}

variable "external_secrets_uami_name_prefix" {
  type        = string
  default     = "uami-extsecrets-"
  description = "Prefix of the External Secrets UAMI. Composed as <prefix><environment>-<location_short_name>."
  nullable    = false
}

variable "oauth2_proxy_app_name_prefix" {
  type        = string
  default     = "oauth2-proxy-"
  description = "Prefix of the oauth2-proxy Entra app registration. Composed as <prefix><aks_cluster_name>."
  nullable    = false
}

variable "kv_secret_name_github_app_id" {
  type        = string
  default     = "github-app-id"
  description = "Key Vault secret name holding the Flux GitHub App ID."
  nullable    = false
}

variable "kv_secret_name_github_app_installation_id" {
  type        = string
  default     = "github-app-installation-id"
  description = "Key Vault secret name holding the Flux GitHub App installation ID."
  nullable    = false
}

variable "kv_secret_name_github_app_private_key" {
  type        = string
  default     = "github-app-private-key"
  description = "Key Vault secret name holding the Flux GitHub App private key."
  nullable    = false
}

variable "flux_namespace" {
  type        = string
  default     = "flux-system"
  description = "Kubernetes namespace into which Flux is installed."
  nullable    = false
}

variable "flux_github_app_secret_name" {
  type        = string
  default     = "flux-system"
  description = "Name of the Kubernetes Secret holding the Flux GitHub App credentials. Defaults to 'flux-system' per the Flux convention."
  nullable    = false
}

variable "cluster_config_configmap_name" {
  type        = string
  default     = "cluster-config"
  description = "Name of the ConfigMap exposing cluster identity / region / domain to manifests."
  nullable    = false
}

variable "workload_identity_configmap_name" {
  type        = string
  default     = "workload-identity-config"
  description = "Name of the ConfigMap exposing workload-identity client IDs to manifests."
  nullable    = false
}

variable "flux_chart_repository" {
  type        = string
  default     = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  description = "OCI repository hosting the flux-operator and flux-instance charts."
  nullable    = false
}

variable "flux_operator_release_name" {
  type        = string
  default     = "flux-operator"
  description = "Helm release name for the flux-operator chart."
  nullable    = false
}

variable "flux_operator_chart_name" {
  type        = string
  default     = "flux-operator"
  description = "Chart name for the flux-operator release."
  nullable    = false
}

variable "flux_instance_release_name" {
  type        = string
  default     = "flux"
  description = "Helm release name for the flux-instance chart."
  nullable    = false
}

variable "flux_instance_chart_name" {
  type        = string
  default     = "flux-instance"
  description = "Chart name for the flux-instance release."
  nullable    = false
}

variable "flux_helm_timeout_seconds" {
  type        = number
  default     = 600
  description = "Helm release timeout (seconds) applied to both flux-operator and flux-instance installs."
  nullable    = false

  validation {
    condition     = var.flux_helm_timeout_seconds > 0
    error_message = "flux_helm_timeout_seconds must be positive."
  }
}

variable "flux_helm_wait" {
  type        = bool
  default     = true
  description = "Whether Helm should wait for release resources to become Ready before returning."
  nullable    = false
}

variable "flux_helm_wait_for_jobs" {
  type        = bool
  default     = true
  description = "Whether Helm should wait for Job resources in the release to complete."
  nullable    = false
}

variable "flux_version" {
  type        = string
  default     = "2.x"
  description = "Flux version semver range (e.g. '2.x', '2.4.x') passed to the flux-instance chart."
  nullable    = false
}

variable "flux_registry" {
  type        = string
  default     = "ghcr.io/fluxcd"
  description = "Container registry from which to pull Flux controller images."
  nullable    = false
}

variable "cluster_type" {
  type        = string
  default     = "azure"
  description = "Kubernetes flavour (kubernetes, openshift, azure, aws, gcp). Drives platform-specific feature gating."
  nullable    = false

  validation {
    condition     = contains(["kubernetes", "openshift", "azure", "aws", "gcp"], var.cluster_type)
    error_message = "cluster_type must be one of: kubernetes, openshift, azure, aws, gcp."
  }
}

variable "cluster_size" {
  type        = string
  default     = "medium"
  description = "T-shirt sizing for Flux controller resource requests (small, medium, large)."
  nullable    = false

  validation {
    condition     = contains(["small", "medium", "large"], var.cluster_size)
    error_message = "cluster_size must be one of: small, medium, large."
  }
}

variable "git_url" {
  type        = string
  description = "Git repository URL to sync from (HTTPS or SSH)."
  nullable    = false
}

variable "git_path" {
  type        = string
  description = "Path within the Git repository where cluster manifests live (e.g. './kubernetes/clusters/production')."
  nullable    = false
}

variable "git_ref" {
  type        = string
  default     = "refs/heads/main"
  description = "Git reference to sync from (refs/heads/<branch> or refs/tags/<tag>)."
  nullable    = false
}

variable "sync_kind" {
  type        = string
  default     = "GitRepository"
  description = "Source kind Flux syncs from (GitRepository, OCIRepository, Bucket)."
  nullable    = false

  validation {
    condition     = contains(["GitRepository", "OCIRepository", "Bucket"], var.sync_kind)
    error_message = "sync_kind must be one of: GitRepository, OCIRepository, Bucket."
  }
}

variable "sync_provider" {
  type        = string
  default     = "github"
  description = "Git provider type (generic, github, gitlab, bitbucket, azure). Enables provider-specific features."
  nullable    = false

  validation {
    condition     = contains(["generic", "github", "gitlab", "bitbucket", "azure"], var.sync_provider)
    error_message = "sync_provider must be one of: generic, github, gitlab, bitbucket, azure."
  }
}
