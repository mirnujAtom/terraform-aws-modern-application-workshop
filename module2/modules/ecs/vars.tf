variable "app_name" {}
variable "app_version" {}
variable "environment" {}
variable "region" {}
variable "account_id" {}
variable "private_subnets" { type = "list"}
variable "vpc_id" {}
variable "lb_target_group_arn" {}
