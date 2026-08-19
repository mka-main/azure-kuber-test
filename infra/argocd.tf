resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.8.28"
  namespace        = "argocd"
  create_namespace = true
  timeout          = 600
  wait             = true

  depends_on = [module.aks, null_resource.push_image]

  values = [
    yamlencode({
      crds = {
        install = true
      }
      dex = {
        enabled = false
      }
      notifications = {
        enabled = false
      }
      applicationSet = {
        enabled = false
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
      server = {
        replicas = 1
        service = {
          type = "LoadBalancer"
        }
        resources = {
          requests = {
            cpu    = "50m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "300m"
            memory = "256Mi"
          }
        }
      }
      controller = {
        replicas = 1
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }
      repoServer = {
        replicas = 1
        resources = {
          requests = {
            cpu    = "50m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }
      redis = {
        resources = {
          requests = {
            cpu    = "25m"
            memory = "64Mi"
          }
          limits = {
            cpu    = "100m"
            memory = "128Mi"
          }
        }
      }
    })
  ]
}

resource "null_resource" "argocd_application" {
  count = var.git_repo_url == "" ? 0 : 1

  depends_on = [helm_release.argocd]

  triggers = {
    repo = var.git_repo_url
    rev  = var.git_revision
    manifest = filesha256("${path.module}/../gitops/application.yaml")
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      az aks get-credentials -g "${azurerm_resource_group.this.name}" -n "${module.aks.cluster_name}" --overwrite-existing
      kubectl wait --for=condition=Established crd/applications.argoproj.io --timeout=180s
      kubectl apply -f "${path.module}/../gitops/application.yaml"
    EOT
  }
}
