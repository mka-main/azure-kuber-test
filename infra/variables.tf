variable "location" {
  type        = string
  description = "Azure region. westeurope rejected new storage on this offer; northeurope is the working region."
  default     = "northeurope"
}

variable "rg_name" {
  type        = string
  description = "Terraform-owned resource group. Keep it separate from leftover CLI-lab resources."
  default     = "mka-tf"
}

variable "unique_suffix" {
  type        = string
  description = "Short lowercase alphanumeric suffix for globally unique names (storage, ACR)."
  default     = "28060"

  validation {
    condition     = can(regex("^[a-z0-9]{3,12}$", var.unique_suffix))
    error_message = "unique_suffix must be 3–12 lowercase letters or digits."
  }
}

variable "aks_name" {
  type        = string
  description = "AKS cluster name."
  default     = "aks-learn"
}

variable "node_vm_size" {
  type        = string
  description = "Node SKU. Standard_B2s is blocked for AKS on this offer; Standard_EC2ads_v5 was allowed."
  default     = "Standard_EC2ads_v5"
}

variable "node_count" {
  type        = number
  description = "System node count. Keep at 1 on Free Trial (~4 vCPU quota)."
  default     = 1
}

variable "git_repo_url" {
  type        = string
  description = "HTTPS Git URL for Argo CD (weekday app in k8s/)."
  default     = "https://github.com/mka-main/azure-kuber-test.git"
}

variable "git_revision" {
  type        = string
  description = "Git branch or tag Argo CD tracks."
  default     = "main"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources."
  default = {
    purpose = "azure-k8s-learning"
    managed = "terraform"
  }
}
