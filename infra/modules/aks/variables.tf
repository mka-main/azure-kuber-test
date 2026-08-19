variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "aks_name" {
  type = string
}

variable "dns_prefix" {
  type        = string
  description = "Globally unique DNS prefix for the API server FQDN."
}

variable "node_vm_size" {
  type = string
}

variable "node_count" {
  type = number
}

variable "acr_id" {
  type        = string
  description = "ACR resource ID for AcrPull on the kubelet identity."
}

variable "tags" {
  type    = map(string)
  default = {}
}
