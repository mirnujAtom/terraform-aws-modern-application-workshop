output "private_subnets" {
  value = "${module.platform.private_subnets}"
}
output "lb_target_group_arn" {
  value = "${module.platform.lb_target_group_arn}"
}
output "lb_address" {
  value = "${module.platform.lb_address}"
}

output "vpc_id" {
  value = "${module.platform.vpc_id}"
}

output "lb_arn" {
  value = "${module.platform.lb_arn}"
}