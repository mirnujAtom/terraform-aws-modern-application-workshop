variable "profile" {}
variable "region" {}
variable "environment" {}
variable "account_id" {}
variable "avz_names" { type = "list" }
variable "vpc_cidr" {}
variable "public_subnets" { type = "list" }
variable "private_subnets" { type = "list" }
variable "app_name" {}