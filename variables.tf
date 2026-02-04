variable "flux_version" {
  type        = string
  default     = "2.x"
  description = <<DESCRIPTION
(Optional) Flux version semver range to deploy. Specifies which Flux version to use.
Examples: "2.x" for latest 2.x, "2.4.x" for specific minor version.
DESCRIPTION
  nullable    = false
}

variable "environment" {
  type        = string
  description = "dev, staging, or prod"
}

variable "private_email" {
  type        = string
  description = "private_email"
  sensitive   = true
}

variable "location_short_name" {
  type        = string
  default     = "swn"
  description = <<DESCRIPTION
(Optional) The location/region short name where the resources are created. Changing this forces a new resource to be created.
DESCRIPTION
  nullable    = false
}


variable "flux_registry" {
  type        = string
  default     = "ghcr.io/fluxcd"
  description = <<DESCRIPTION
(Optional) Flux distribution registry URL. Specifies the container registry from which to pull Flux images.
Defaults to the official Flux registry.
DESCRIPTION
  nullable    = false
}

variable "cluster_type" {
  type        = string
  default     = "azure"
  description = <<DESCRIPTION
(Optional) The type of Kubernetes cluster. This affects how Flux configures certain platform-specific features.
Possible values are: kubernetes, openshift, azure, aws, gcp.
Defaults to azure.
DESCRIPTION
  nullable    = false

  validation {
    condition     = contains(["kubernetes", "openshift", "azure", "aws", "gcp"], var.cluster_type)
    error_message = "Cluster type must be one of: kubernetes, openshift, azure, aws, gcp."
  }
}

variable "cluster_size" {
  type        = string
  default     = "medium"
  description = <<DESCRIPTION
(Optional) The size of the cluster which determines resource allocations for Flux controllers.
- small: For development/test clusters with minimal workloads
- medium: For production clusters with moderate workloads (recommended)
- large: For production clusters with high workloads
Defaults to medium.
DESCRIPTION
  nullable    = false

  validation {
    condition     = contains(["small", "medium", "large"], var.cluster_size)
    error_message = "Cluster size must be one of: small, medium, large."
  }
}

variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
  default     = ""
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID"
  type        = string
  default     = ""
}

variable "github_app_pem" {
  description = "The contents of the GitHub App private key PEM file"
  sensitive   = true
  type        = string
  default     = ""
}

variable "git_url" {
  type        = string
  nullable    = false
  description = <<DESCRIPTION
(Required) The Git repository URL to sync from. Must be a valid HTTPS or SSH Git URL.
Examples:
- HTTPS: https://github.com/org/repo
- SSH: ssh://git@github.com/org/repo.git
DESCRIPTION
}

variable "git_path" {
  type        = string
  nullable    = false
  description = <<DESCRIPTION
(Required) Path within the Git repository where cluster manifests are located.
Must start with ./ and point to a valid directory path.
Example: ./kubernetes/clusters/production
DESCRIPTION
}

variable "cluster_domain" {
  type        = string
  default     = "cluster.local"
  description = <<DESCRIPTION
(Optional) The DNS domain name used within the Kubernetes cluster for service discovery.
Defaults to cluster.local.
DESCRIPTION
}

variable "git_ref" {
  type        = string
  default     = "refs/heads/main"
  description = <<DESCRIPTION
(Optional) Git reference to sync from. Specifies which branch or tag to track.
Format:
- Branch: refs/heads/BRANCH_NAME
- Tag: refs/tags/TAG_NAME
Defaults to refs/heads/main.
DESCRIPTION

}

variable "sync_kind" {
  type        = string
  default     = "GitRepository"
  description = <<DESCRIPTION
(Optional) The kind of source to sync from. Determines how Flux fetches manifests.
Possible values are: GitRepository, OCIRepository, Bucket.
Defaults to GitRepository.
DESCRIPTION

  validation {
    condition     = contains(["GitRepository", "OCIRepository", "Bucket"], var.sync_kind)
    error_message = "Sync kind must be one of: GitRepository, OCIRepository, Bucket."
  }
}

variable "sync_provider" {
  type        = string
  default     = "github"
  description = <<DESCRIPTION
(Optional) Git provider type. Enables provider-specific optimizations and features.
Possible values are: generic, github, gitlab, bitbucket, azure.
Defaults to github.
DESCRIPTION

  validation {
    condition     = contains(["generic", "github", "gitlab", "bitbucket", "azure"], var.sync_provider)
    error_message = "Sync provider must be one of: generic, github, gitlab, bitbucket, azure."
  }
}

variable "kv_name" {
  type        = string
  description = "The name of the Key Vault."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.kv_name))
    error_message = "The name must be between 3 and 24 characters long and can only contain letters, numbers and dashes."
  }
  validation {
    error_message = "The name must not contain two consecutive dashes"
    condition     = !can(regex("--", var.kv_name))
  }
  validation {
    error_message = "The name must start with a letter"
    condition     = can(regex("^[a-zA-Z]", var.kv_name))
  }
  validation {
    error_message = "The name must end with a letter or number"
    condition     = can(regex("[a-zA-Z0-9]$", var.kv_name))
  }
}

variable "subscription_id" {
  description = "Name of the subscription"
  type        = string
}

variable "github_token" {
  type        = string
  description = "The GitHub Flux/Runner Controller access token."
  sensitive   = true
}

variable "aks_cluster_name" {
  type        = string
  default     = null
  description = "(Optional) The name for the AKS resources created in the specified Azure Resource Group. This variable overwrites the 'prefix' var (The 'prefix' var will still be applied to the dns_prefix if it is set)"
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}


variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
