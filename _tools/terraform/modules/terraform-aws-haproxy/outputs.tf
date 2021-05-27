output "sg_haproxy" {
  value = aws_security_group.haproxy.id
}

output "haproxy_alb_dns_name" {
  value = aws_lb.haproxy.dns_name
}

output "haproxy_alb_zone_id" {
  value = aws_lb.haproxy.zone_id
}

output "haproxy_alb_private_fqdn" {
  value = var.alb_internal ? aws_route53_record.private.0.fqdn : ""
}

output "haproxy_alb_public_fqdn" {
  value = !var.alb_internal ? aws_route53_record.public.0.fqdn : ""
}