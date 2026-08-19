# Azure + Kubernetes learning lab

Repo: [github.com/mka-main/azure-kuber-test](https://github.com/mka-main/azure-kuber-test)

One `terraform apply` creates Azure infra, builds/pushes the weekday image to ACR, installs Argo CD, and registers the GitOps app (`k8s/`).

## Raise everything

Needs: `az login`, Docker running, `ARM_SUBSCRIPTION_ID`.

```bash
az login
export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"

cd infra
cp terraform.tfvars.example terraform.tfvars   # optional; defaults already match this repo
terraform init
terraform plan
terraform apply
```

Then:

```bash
az aks get-credentials -g mka-tf -n aks-learn --overwrite-existing
kubectl get svc myapp
kubectl -n argocd get pods
```

Argo CD UI (user `admin`). Password — print locally, do not commit:

```bash
kubectl -n argocd port-forward svc/argocd-server 8081:80
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```

Open `http://127.0.0.1:8081` → application **weekday**.

## What Terraform creates

| Resource | Name | Notes |
| --- | --- | --- |
| Resource group | `mka-tf` | Separate from leftover CLI lab in `mka-main` |
| Storage + container | `stmkatf28060` / `data` | Standard LRS |
| ACR | `acrmkatf28060` | Basic, AcrPull on the AKS kubelet |
| Image | `acrmkatf28060.azurecr.io/myapp:v2` | `docker build` + push during apply |
| Log Analytics | `log-aks-learn` | Container Insights, 1 GB/day cap |
| AKS | `aks-learn` | Free tier, 1× `Standard_EC2ads_v5`, Azure CNI Overlay |
| Argo CD | namespace `argocd` | Helm; Application `weekday` tracks `k8s/` on `main` |

## Cost and teardown

Control plane is free. The node bills while the cluster exists (~$0.15/hr). Destroy when done:

```bash
cd infra
terraform destroy
```
