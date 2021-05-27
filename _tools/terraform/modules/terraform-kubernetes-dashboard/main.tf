locals {
  k8s_resources_labels = merge({
    "born2scale.io/terraform-module" = "kube-dashboard",
  }, var.k8s_resources_labels)

  k8s_deployment_labels_selector = {
    "born2scale.io/service" = "kubernetes-dashboard",
    "born2scale.io/process" = "bootstrap",
    "born2scale.io/unit"    = "dashboard",
  }

  k8s_deployment_labels_selector_metrics = {
    "born2scale.io/service" = "kubernetes-dashboard",
    "born2scale.io/process" = "bootstrap",
    "born2scale.io/unit"    = "metrics-scraper",
  }

  k8s_deployment_labels         = merge(local.k8s_deployment_labels_selector, local.k8s_resources_labels)
  k8s_deployment_labels_metrics = merge(local.k8s_deployment_labels_selector_metrics, local.k8s_resources_labels)

  k8s_deployment_image                 = "${var.k8s_deployment_image_registry}:${var.k8s_deployment_image_tag}"
  k8s_deployment_metrics_scraper_image = "${var.k8s_deployment_metrics_scraper_image_registry}:${var.k8s_deployment_metrics_scraper_image_tag}"
}

resource "kubernetes_namespace" "kubernetes_dashboard" {
  count = var.k8s_namespace_create && var.enabled ? 1 : 0

  metadata {
    name = var.k8s_namespace
  }
}

resource "kubernetes_service_account" "kubernetes_dashboard" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "${var.k8s_resources_name_prefix}kubernetes-dashboard"
    namespace = var.k8s_namespace
    labels    = local.k8s_resources_labels
  }
}

resource "kubernetes_secret" "kubernetes_dashboard_certs" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "kubernetes-dashboard-certs"
    namespace = var.k8s_namespace
    labels    = local.k8s_resources_labels
  }

  type = "Opaque"

  lifecycle {
    ignore_changes = [
      data,
    ]
  }
}

resource "kubernetes_secret" "kubernetes_dashboard_csrf" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "kubernetes-dashboard-csrf"
    namespace = var.k8s_namespace
    labels    = local.k8s_resources_labels
  }

  type = "Opaque"

  data = {
    csrf = var.k8s_dashboard_csrf
  }
}

resource "kubernetes_secret" "kubernetes_dashboard_key_holder" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "kubernetes-dashboard-key-holder"
    namespace = var.k8s_namespace
  }

  type = "Opaque"

  lifecycle {
    ignore_changes = [
      data,
    ]
  }
}


resource "kubernetes_config_map" "kubernetes_dashboard_settings" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "kubernetes-dashboard-settings"
    namespace = var.k8s_namespace
    labels    = local.k8s_resources_labels
  }

  lifecycle {
    ignore_changes = [
      data,
    ]
  }
}

resource "kubernetes_role" "kubernetes_dashboard" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "${var.k8s_resources_name_prefix}kubernetes-dashboard"
    namespace = var.k8s_namespace
    labels    = local.k8s_resources_labels
  }

  rule {
    api_groups = [
    ""]
    resources = [
    "secrets"]
    resource_names = [
      kubernetes_secret.kubernetes_dashboard_key_holder.0.metadata.0.name,
      kubernetes_secret.kubernetes_dashboard_certs.0.metadata.0.name,
      kubernetes_secret.kubernetes_dashboard_csrf.0.metadata.0.name,
    ]
    verbs = [
      "get",
      "update",
    "delete"]
  }

  rule {
    api_groups = [
    ""]
    resources = [
    "configmaps"]
    resource_names = [
    kubernetes_config_map.kubernetes_dashboard_settings.0.metadata.0.name]
    verbs = [
      "get",
    "update"]
  }

  rule {
    api_groups = [
    ""]
    resources = [
    "services"]
    resource_names = [
      "heapster",
      kubernetes_service.kubernetes_metrics_scraper.0.metadata.0.name,
    ]
    verbs = [
    "proxy"]
  }

  rule {
    api_groups = [
    ""]
    resources = [
    "services/proxy"]
    resource_names = [
      "heapster",
      "http:heapster:",
      "https:heapster:",
      kubernetes_service.kubernetes_metrics_scraper.0.metadata.0.name,
      "http:${kubernetes_service.kubernetes_metrics_scraper.0.metadata.0.name}",
    ]
    verbs = [
    "get"]
  }
}

resource "kubernetes_role_binding" "kubernetes_dashboard" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "${var.k8s_resources_name_prefix}kubernetes-dashboard"
    namespace = var.k8s_namespace
    labels    = local.k8s_resources_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.kubernetes_dashboard.0.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kubernetes_dashboard.0.metadata.0.name
    namespace = kubernetes_service_account.kubernetes_dashboard.0.metadata.0.namespace
  }
}

resource "kubernetes_cluster_role" "kubernetes_dashboard" {
  count = var.enabled ? 1 : 0
  metadata {
    name   = "${var.k8s_resources_name_prefix}kubernetes-dashboard"
    labels = local.k8s_resources_labels
  }

  rule {
    api_groups = [
    "metrics.k8s.io"]
    resources = [
      "pods",
    "nodes"]
    verbs = [
      "get",
      "list",
    "watch"]
  }

  rule {
    api_groups = [
    ""]
    resources = [
    "nodes", "namespaces", "pods", "serviceaccounts", "services", "configmaps", "endpoints", "persistentvolumeclaims", "replicationcontrollers", "replicationcontrollers/scale", "persistentvolumeclaims", "persistentvolumes", "bindings", "events", "limitranges", "namespaces/status", "pods/log", "pods/status", "replicationcontrollers/status", "resourcequotas", "resourcequotas/status"]
    verbs = [
      "get",
      "list",
    "watch"]
  }

  rule {
    api_groups = [
    "apps"]
    resources = [
    "daemonsets", "deployments", "deployments/scale", "replicasets", "replicasets/scale", "statefulsets"]
    verbs = [
      "get",
      "list",
    "watch"]
  }
  rule {
    api_groups = [
    "autoscaling"]
    resources = [
    "horizontalpodautoscalers"]
    verbs = [
      "get",
      "list",
    "watch"]
  }
  rule {
    api_groups = [
    "batch"]
    resources = [
    "cronjobs", "jobs"]
    verbs = [
      "get",
      "list",
    "watch"]
  }
  rule {
    api_groups = [
    "extensions"]
    resources = [
    "daemonsets", "deployments", "deployments/scale", "networkpolicies", "replicasets", "replicasets/scale", "replicationcontrollers/scale"]
    verbs = [
      "get",
      "list",
    "watch"]
  }
  rule {
    api_groups = [
    "networking.k8s.io"]
    resources = [
    "ingresses", "networkpolicies"]
    verbs = [
      "get",
      "list",
    "watch"]
  }
  rule {
    api_groups = [
    "policy"]
    resources = [
    "poddisruptionbudgets"]
    verbs = [
      "get",
      "list",
    "watch"]
  }
  rule {
    api_groups = [
    "storage.k8s.io"]
    resources = [
    "storageclasses", "volumeattachments"]
    verbs = [
      "get",
      "list",
    "watch"]
  }
  rule {
    api_groups = [
    "rbac.authorization.k8s.io"]
    resources = [
    "clusterrolebindings", "clusterroles", "roles", "rolebindings"]
    verbs = [
      "get",
      "list",
    "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "kubernetes_dashboard" {
  count = var.enabled ? 1 : 0
  metadata {
    name   = "${var.k8s_resources_name_prefix}kubernetes-dashboard"
    labels = local.k8s_resources_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kubernetes_dashboard.0.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kubernetes_dashboard.0.metadata.0.name
    namespace = kubernetes_service_account.kubernetes_dashboard.0.metadata.0.namespace
  }
}

resource "kubernetes_deployment" "kubernetes_dashboard" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "${var.k8s_resources_name_prefix}kubernetes-dashboard"
    namespace = var.k8s_namespace
    labels    = local.k8s_resources_labels
  }

  spec {
    replicas               = 1
    revision_history_limit = 10

    selector {
      match_labels = local.k8s_deployment_labels_selector
    }

    template {
      metadata {
        labels = local.k8s_deployment_labels
      }

      spec {
        service_account_name            = kubernetes_service_account.kubernetes_dashboard.0.metadata.0.name
        automount_service_account_token = true

        container {
          image = local.k8s_deployment_image
          name  = "kubernetes-dashboard"

          args = [
            "--auto-generate-certificates",
            "--namespace=${var.k8s_namespace}",
          ]

          port {
            container_port = 8443
            protocol       = "TCP"
          }

          volume_mount {
            name       = "kubernetes-dashboard-certs"
            mount_path = "/certs"
          }

          volume_mount {
            name       = "tmp-volume"
            mount_path = "/tmp"
          }

          liveness_probe {
            http_get {
              scheme = "HTTPS"
              path   = "/"
              port   = 8443
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_user                = 1001
            run_as_group               = 2001
          }

          image_pull_policy = "Always"
        }

        volume {
          name = "kubernetes-dashboard-certs"
          secret {
            secret_name = kubernetes_secret.kubernetes_dashboard_certs.0.metadata.0.name
          }
        }

        volume {
          name = "tmp-volume"
          empty_dir {

          }
        }

        node_selector = var.k8s_deployment_node_selector

        dynamic toleration {
          for_each = var.k8s_deployment_tolerations
          content {
            key      = toleration.value.key
            operator = toleration.value.operator
            value    = toleration.value.value
            effect   = toleration.value.effect
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "kubernetes_metrics_scraper" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "${var.k8s_resources_name_prefix}kubernetes-metrics-scraper"
    namespace = var.k8s_namespace
    labels    = local.k8s_resources_labels
  }

  spec {
    replicas               = 1
    revision_history_limit = 10

    selector {
      match_labels = local.k8s_deployment_labels_selector_metrics
    }

    template {
      metadata {
        labels = local.k8s_deployment_labels_metrics
      }

      spec {
        service_account_name            = kubernetes_service_account.kubernetes_dashboard.0.metadata.0.name
        automount_service_account_token = true

        container {
          image = local.k8s_deployment_metrics_scraper_image
          name  = "kubernetes-metrics-scraper"

          port {
            container_port = 8000
            protocol       = "TCP"
          }

          volume_mount {
            name       = "tmp-volume"
            mount_path = "/tmp"
          }

          liveness_probe {
            http_get {
              scheme = "HTTP"
              path   = "/"
              port   = 8000
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_user                = 1001
            run_as_group               = 2001
          }

          image_pull_policy = "Always"
        }

        volume {
          name = "tmp-volume"
          empty_dir {

          }
        }

        node_selector = var.k8s_deployment_node_selector

        dynamic toleration {
          for_each = var.k8s_deployment_tolerations
          content {
            key      = toleration.value.key
            operator = toleration.value.operator
            value    = toleration.value.value
            effect   = toleration.value.effect
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "kubernetes_dashboard" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "${var.k8s_resources_name_prefix}kubernetes-dashboard"
    namespace = var.k8s_namespace
    labels    = local.k8s_resources_labels
  }

  spec {
    selector = local.k8s_deployment_labels_selector

    port {
      port        = 443
      target_port = 8443
    }
  }
}

resource "kubernetes_service" "kubernetes_metrics_scraper" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "${var.k8s_resources_name_prefix}dashboard-metrics-scraper"
    namespace = var.k8s_namespace
    labels    = local.k8s_resources_labels
  }

  spec {
    selector = local.k8s_deployment_labels_selector_metrics

    port {
      port        = 8000
      target_port = 8000
    }
  }
}