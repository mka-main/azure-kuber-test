# Azure + Kubernetes learning lab

Repo: [github.com/mka-main/azure-kuber-test](https://github.com/mka-main/azure-kuber-test)

One `terraform apply` creates Azure infra, builds/pushes the weekday image to ACR, installs Argo CD, and registers three GitOps apps: **weekday-dev**, **weekday-qa**, **weekday-stage**.

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
kubectl -n argocd get applications
kubectl get svc -A -l app=myapp
```

Argo CD UI (user `admin`). Password — print locally, do not commit:

```bash
kubectl -n argocd port-forward svc/argocd-server 8081:80
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```

Open `http://127.0.0.1:8081`. You should see **weekday-dev**, **weekday-qa**, **weekday-stage**.

Dev and qa auto-sync from `main`. Stage is **manual**: after a Git change, click **Sync** on **weekday-stage** (or it stays OutOfSync on purpose).

## Environments (dev / qa / stage)

Same app, three namespaces. Shared manifests live in `k8s/base/`; per-env diffs are Kustomize overlays. Argo Applications live in `gitops/`.

| Argo app | Git path | Namespace | Replicas | `APP_ENV` | Sync |
| --- | --- | --- | --- | --- | --- |
| weekday-dev | `k8s/overlays/dev` | `dev` | 1 | `dev` | auto |
| weekday-qa | `k8s/overlays/qa` | `qa` | 1 | `qa` | auto |
| weekday-stage | `k8s/overlays/stage` | `stage` | 2 | `stage` | manual |

All three currently use the same image tag `myapp:v2`. Promotion is changing `newTag` in an overlay and pushing `main` — not editing live pods.

```bash
# IPs (LoadBalancer per env)
kubectl get svc -n dev myapp
kubectl get svc -n qa myapp
kubectl get svc -n stage myapp

# replicas + env
kubectl get deploy -n dev myapp
kubectl exec -n dev deploy/myapp -- printenv APP_ENV
```

If Argo still shows the old single app **weekday** in `default`, Terraform deletes it on the next apply. You can also run:

```bash
kubectl apply -f gitops/
kubectl delete application weekday -n argocd --ignore-not-found
```

Argo reads GitHub, not your laptop: push overlays to `main` before the new Applications can sync.

## What Terraform creates

| Resource | Name | Notes |
| --- | --- | --- |
| Resource group | `mka-tf` | Separate from leftover CLI lab in `mka-main` |
| Storage + container | `stmkatf28060` / `data` | Standard LRS |
| ACR | `acrmkatf28060` | Basic, AcrPull on the AKS kubelet |
| Image | `acrmkatf28060.azurecr.io/myapp:v2` | `docker build` + push during apply |
| Log Analytics | `log-aks-learn` | Container Insights, 1 GB/day cap |
| AKS | `aks-learn` | Free tier, 1× `Standard_EC2ads_v5`, Azure CNI Overlay |
| Argo CD | namespace `argocd` | Helm; three Applications track `k8s/overlays/{dev,qa,stage}` on `main` |

## Cost and teardown

Control plane is free. The node bills while the cluster exists (~$0.15/hr). Three LoadBalancer Services each get a public IP. Destroy when done:

```bash
cd infra
terraform destroy
```
