terraform {
  required_version = ">= 1.9.0, < 2.0.0"
  required_providers {
    azurerm    = { source = "hashicorp/azurerm", version = "~> 4.57" }
    azuread    = { source = "hashicorp/azuread", version = "~> 3.8" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 3.0" }
    helm       = { source = "hashicorp/helm", version = "~> 3.1" }
    random     = { source = "hashicorp/random", version = "~> 3.9" }
  }
}
