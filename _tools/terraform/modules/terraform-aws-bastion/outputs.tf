output "bastion_sg" {
  value = aws_security_group.bastion.id
}

output "bastion_asg_id" {
  value = aws_autoscaling_group.bastion.*.id
}

output "ssh_from_bastion" {
  value = aws_security_group.ssh-from-bastion.id
}