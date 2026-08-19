provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  # AzureRM v4 requires a subscription. Set ARM_SUBSCRIPTION_ID in the
  # environment (do not commit the value):
  #   export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
}

provider "helm" {
  kubernetes {
    host                   = module.aks.kube_host
    client_certificate     = base64decode(module.aks.kube_client_certificate)
    client_key             = base64decode(module.aks.kube_client_key)
    cluster_ca_certificate = base64decode(module.aks.kube_cluster_ca_certificate)
  }
}
