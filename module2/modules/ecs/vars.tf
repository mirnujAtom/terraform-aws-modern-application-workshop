variable "app_name" {}
variable "environment" {}
variable "region" {}
variable "ecs_service_role_arn" {}
variable "ecs_task_role_arn" {}
variable "app_image" {}
variable "private_subnets" { type = "list"}
variable "fg_sg_id" {}
variable "lb_target_group_arn" {}
