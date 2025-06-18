variable "traefik_namespace" {
  description = "Namespace for Traefik"
  type        = string
}

variable "traefik_version" {
  description = "Version of Traefik chart"
  type        = string
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
}

variable "argocd_version" {
  description = "Version of ArgoCD chart"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for public FQDNs"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}