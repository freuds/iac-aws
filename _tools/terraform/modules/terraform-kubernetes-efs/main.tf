resource "kubernetes_config_map" "efs-config" {
  metadata {
    name   = "${var.env}-${var.service}-${var.role}"
    labels = {
      "name" = "efs-config",
      "role" = "configmap"
    }
  }

  data = {
    "file.system.id"   = var.file_system_id
    "aws.region"       = var.region
    "provisioner.name" = "aws.io/aws-efs"
    "dns.name"         = var.efs_dns_name
  }
}

resource "kubernetes_storage_class" "efs-sc" {
  metadata {
    name = "${var.env}-${var.service}-storage-class"
  }
  storage_provisioner = "aws.io/aws-efs"
  reclaim_policy      = var.reclaim_policy
  mount_options       = [
    "file_mode=0777",
    "dir_mode=0777",
    "mfsymlinks",
    "nobrl",
    "cache=none"]
}

resource "kubernetes_csi_driver" "efs-csi-driver" {
  metadata {
    name = "efs-csi-driver"
  }

  spec {
    attach_required        = true
    pod_info_on_mount      = true
    volume_lifecycle_modes = [
      "Persistent"]
  }
}

resource "kubernetes_persistent_volume_claim" "efs-storage-claim" {
  depends_on = [
    kubernetes_persistent_volume.efs-pv,
    kubernetes_storage_class.efs-sc
  ]
  metadata {
    name        = "${var.env}-${var.service}-storage-claim"
    annotations = {
      "volume.beta.kubernetes.io/storage-class" = kubernetes_storage_class.efs-sc.metadata.0.name
    }
  }
  spec {
    access_modes = [
      "ReadWriteMany"]
    resources {
      requests = {
        storage = var.pvc_storage_size
      }
    }
    volume_name  = "${var.env}-${var.service}-pv"
  }
}

resource "kubernetes_persistent_volume" "efs-pv" {
  depends_on = [
    kubernetes_storage_class.efs-sc
  ]
  metadata {
    name = "${var.env}-${var.service}-pv"
  }
  spec {
    storage_class_name = kubernetes_storage_class.efs-sc.metadata.0.name
    capacity           = {
      storage = var.pv_storage_size
    }
    access_modes       = [
      "ReadWriteMany"]
    mount_options = [
      "tls",
      "accesspoint=${var.efs_access_point}"
    ]
    persistent_volume_source {
      csi {
        driver        = "efs.csi.aws.com"
        volume_handle = "${var.file_system_id}::${var.efs_access_point}"
      }
    }
  }
}