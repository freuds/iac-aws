output "file_system_id" {
  value       = aws_efs_file_system.efs-fs.id
  description = "efs file system id"
}

output "mount_target_dns_efs" {
  description = "Address of the mount target provisioned."
  value       = aws_efs_mount_target.mount-efs.0.dns_name
}

output "efs_access_point" {
  description = "efs access point"
  value       = aws_efs_access_point.efs-ap.id
}