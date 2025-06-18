provider "kubernetes" {
  config_path = "~/.kube/aks-config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/aks-config"
  }
}

resource "kubernetes_ingress_class" "traefik" {
  metadata {
    name = "traefik"
  }

  spec {
    controller = "traefik.io/ingress-controller"
  }
}

resource "kubernetes_namespace" "traefik" {
  metadata {
    name = var.traefik_namespace
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = var.traefik_version
  depends_on = [kubernetes_ingress_class.traefik]
  namespace  = kubernetes_namespace.traefik.metadata[0].name

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "deployment.replicas"
    value = "2"
  }

  set {
    name  = "dashboard.enabled"
    value = "true"
  }

  set {
    name  = "dashboard.ingress.enabled"
    value = "true"
  }

  set {
    name  = "dashboard.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "traefik"
  }

  set {
    name  = "dashboard.ingress.entrypoints[0]"
    value = "websecure"
  }

  set {
    name  = "dashboard.ingress.routes[0].match"
    value = "Host(`traefik.${var.dns_prefix}.${var.location}.cloudapp.azure.com`) && PathPrefix(`/dashboard`)"
  }

  set {
    name  = "dashboard.ingress.routes[0].kind"
    value = "Rule"
  }

  set {
    name  = "dashboard.ingress.annotations.traefik\\.ingress\\.kubernetes\\.io/router\\.tls"
    value = "true"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_version
  depends_on = [kubernetes_ingress_class.traefik]
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }
  set {
    name  = "server.ingress.enabled"
    value = "true"
  }
  set {
    name  = "server.ingress.hosts[0]"
    value = "argocd.${var.dns_prefix}.${var.location}.cloudapp.azure.com"
  }
  set {
    name  = "server.ingress.ingressClassName"
    value = "traefik"
  }
  set {
    name  = "server.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "traefik"
  }
  set {
    name  = "server.ingress.annotations.traefik\\.ingress\\.kubernetes\\.io/router\\.entrypoints"
    value = "websecure"
  }
  set {
    name  = "server.ingress.annotations.traefik\\.ingress\\.kubernetes\\.io/router\\.tls"
    value = "true"
  }
  set {
    name  = "redis.enabled"
    value = "true"
  }
  set {
    name  = "controller.replicas"
    value = "2"
  }
  set {
    name  = "repoServer.replicas"
    value = "2"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "kubernetes_config_map" "argocd_rbac" {
  metadata {
    name = "argocd-rbac-custom"
    namespace = var.argocd_namespace
    labels = {
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  data = {
    "policy.csv" = <<-EOT
p, role:org-admin, applications, *, */*, allow
p, role:org-admin, clusters, get, *, allow
p, role:org-admin, repositories, get, *, allow
p, role:org-admin, repositories, create, *, allow
p, role:org-admin, repositories, update, *, allow
p, role:org-admin, repositories, delete, *, allow
g, org-admin, role:org-admin
EOT
  }
}

resource "null_resource" "patch_argocd_rbac_env" {
  depends_on = [helm_release.argocd, kubernetes_config_map.argocd_rbac]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl -n ${var.argocd_namespace} set env deployment/argocd-server \
        ARGOCD_RBAC_POLICY_CSV="$(kubectl get configmap argocd-rbac-custom -n ${var.argocd_namespace} -o jsonpath='{.data.policy\\.csv}')"
    EOT
  }
}

# Patching the admin password for ArgoCD
# resource "null_resource" "patch_argocd_admin_password" {
#   depends_on = [helm_release.argocd]

#   provisioner "local-exec" {
#     command = <<-EOT
#       kubectl -n ${var.argocd_namespace} patch secret argocd-secret \
#         -p '{"stringData": {"admin.password": "$2a$10$rRyBsGSHK6.uc8fntPwVIuLVHgsAhAX7TcdrqW/RADU0uh7CaChLa"}}'
#     EOT
#   }
# }
# resource "null_resource" "restart_argocd_server" {
#   depends_on = [null_resource.patch_argocd_admin_password]

#   provisioner "local-exec" {
#     command = "kubectl -n ${var.argocd_namespace} delete pod -l app.kubernetes.io/name=argocd-server"
#   }
# }
