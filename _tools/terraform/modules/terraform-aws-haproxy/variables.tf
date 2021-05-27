variable "service" {
  default = "haproxy"
}

variable "env" {

}

variable "role" {
  default = "server"
}

variable "region" {
  default = "eu-west-1"
}

variable "azs" {
  type    = map(list(string))
  default = {
    eu-west-1 = [
      "eu-west-1a",
      "eu-west-1b",
      "eu-west-1c"]
  }
}

variable "vpc_id" {
}


variable "vpc_dns_srv_ip" {
}

variable "trusted_networks" {
  default = [
    "0.0.0.0/0"
  ]
}

variable "haproxy_alb_subnets" {
}

variable "haproxy_subnets" {
}

variable "cross_zone_load_balancing" {
  type    = bool
  default = true
}

variable "alb_internal" {
  type    = bool
  default = false
}

variable "loadbalancer_type" {
  default = "application"
}

variable "haproxy_instances_port" {
  default = 80
}

variable "haproxy_instances_protocol" {
  default = "HTTP"
}

variable "alb_port" {
  default = 80
}

variable "alb_protocol" {
  default = "HTTP"
}

variable "alb_ssl_enabled" {
  default = false
}

variable "alb_ssl_certificate_arn" {
}

variable "alb_prod_ssl_certificate_arn" {
}

variable "healthcheck_healthy_threshold" {
  default = 2
}
variable "healthcheck_unhealthy_threshold" {
  default = 2
}
variable "healthcheck_timeout" {
  default = 2
}
variable "healthcheck_interval" {
  default = 5
}

variable "healthcheck_url" {
  default = "/healthz"
}

variable "haproxy_instances_port_secure" {
  default = 443
}

variable "haproxy_instances_protocol_secure" {
  default = "HTTPS"
}

variable "alb_port_secure" {
  default = 443
}

variable "alb_protocol_secure" {
  default = "HTTPS"
}

variable "extra_userdata" {
  default = ""
}

variable "s3_vault_bucket" {
}

variable "haproxy_ami_id" {
}

variable "haproxy_instance_type" {
  default = "t3.micro"
}

variable "haproxy_asg_wait_for_elb_capacity" {
  default = 0
}

variable "key_name" {
}

variable "haproxy_root_block_device_volume_size" {
  default = 8
}

variable "haproxy_multizone" {
  default = false
}

variable "haproxy_num_zone" {
  default = 1
}

variable "ssh_from_bastion_sg" {
}

variable "haproxy_asg_min" {
  default = 0
}

variable "haproxy_asg_max" {
  default = 3
}

variable "haproxy_asg_desired" {
  default = 1
}

variable "r53_private_zone" {
  type = string
}

variable "r53_public_zone" {
  type = string
}

variable "alb_public_aliases" {
  type = set(string)
  default = []
}

variable "alb_private_aliases" {
  type = set(string)
  default = []
}

variable "start_stop_enabled" {
  description = "Whether or not daily start / stop of haproxy instances is enabled"
  default = true
  type = bool
}

variable "alb_access_logs_enabled" {
  description = "Enabled or not access_log for ELB/ALB"
  default = false
}

variable "alb_access_logs_interval_time" {
  default = 60
  description = "Default interval time to access log"
}

variable "alb_access_logs_bucket_prefix" {
  default = "logs"
}

variable "alb_access_logs_bucket_name" {
  default = ""
}