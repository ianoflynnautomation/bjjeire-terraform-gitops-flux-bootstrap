# Flux Bootstrap for AKS

Terraform module to bootstrap Flux on Azure Kubernetes Service using the Flux Operator pattern with Azure Workload Identity.

## Architecture

- **Flux Operator**: Manages Flux instance lifecycle via Helm
- **Flux Instance**: Configures GitRepository sync with custom patches for AKS
- **Workload Identity**: Enables Azure resource access without static credentials
- **ConfigMaps**: Injects cluster metadata (region, Key Vault, tenant ID) into flux-system namespace

## Prerequisites

- Existing AKS cluster with admin access
- Azure managed identity named `{cluster-name}-flux-identity` with required RBAC
- Azure Key Vault accessible by the managed identity
- GitHub token with repo access

## Usage

```hcl
module "flux_bootstrap" {
  source = "."

  # Required
  git_url             = "https://github.com/org/repo"
  git_path            = "./clusters/production"
  aks_cluster_name    = "bjjeire-aks"
  resource_group_name = "bjjeire-rg"
  subscription_id     = "00000000-0000-0000-0000-000000000000"
  kv_name             = "bjjeire-kv"
  github_token        = var.github_token

  # Optional
  git_ref         = "refs/heads/main"
  flux_version    = "2.x"
  cluster_type    = "azure"
  cluster_size    = "medium"
  sync_provider   = "github"
}
```

## Environments

Environment-specific variables are stored in [environments/](environments/):
- `dev/terraform.tfvars`
- `staging/terraform.tfvars`

Apply with: `terraform apply -var-file=environments/dev/terraform.tfvars`

## What Gets Deployed

1. `flux-system` namespace
2. GitHub credentials secret
3. Cluster and workload identity ConfigMaps
4. Flux Operator (Helm chart)
5. Flux Instance (Helm chart) with GitRepository source

Flux syncs manifests from the configured Git path on a 1-minute interval.

## Outputs

- `flux_namespace`: Namespace where Flux is installed
- `flux_identity_client_id`: Azure Workload Identity client ID

## License

MIT
