terraform {
  required_version = ">= 1.7"
  required_providers {
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 3.0.1" }
    helm       = { source = "hashicorp/helm", version = "~> 3.1.1" }
    azurerm    = { source = "hashicorp/azurerm", version = "~> 4.57.0" }
  }
}
