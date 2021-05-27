variable "region" {
  default = "eu-west-1"
}

variable "auth0_domain" {

}

variable "env" {

}

variable "admin_role_name" {
  default = "devops"
}

variable "user_role_name" {
  default = "user"
}

variable "auth0_client_id" {

}

variable "org" {

}

variable "aws_users_bucket_path" {

}

variable "aws_users" {
  type = map(object(
    {
      github_user    = string,
      gcloud_email   = string,
      aws_roles      = list(string),
      bastion_user   = string,
      ssh_public_key = string
  }))
}

variable "auth0_ips" {
  type = list(string)
  default = [
    "52.28.56.226",
    "52.28.45.240",
    "52.16.224.164",
    "52.16.193.66",
    "34.253.4.94",
    "52.50.106.250",
    "52.211.56.181",
    "52.213.38.246",
    "52.213.74.69",
    "52.213.216.142",
    "35.156.51.163",
    "35.157.221.52",
    "52.28.184.187",
    "52.28.212.16",
    "52.29.176.99",
    "52.57.230.214",
    "54.76.184.103",
    "52.210.122.50",
    "52.208.95.174",
    "52.210.122.50",
    "52.208.95.174",
    "54.76.184.103"
  ]
}

variable "key_pair_name" {
  default = "key-name"
}

variable "key_pair_public_key" {
  default = "ssh-rsa YOUR_PUBLIC_KEY example@example.com"
}

variable "vpc_endpoint_enabled" {
  default = false
}
variable "vpc_id" {
  default = ""
}

variable "lifetime_in_seconds" {
  description = "Lifetime definition in seconds"
  default     = 3600
}