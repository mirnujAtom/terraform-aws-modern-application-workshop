output "public_subnets" { value = "${module.vpc.public_subnets}" }
output "private_subnets" { value = "${module.vpc.private_subnets}" }
output "vpc_id" { value = "${module.vpc.vpc_id}" }
output "vpc_cidr" { value = "${var.vpc_cidr}" }
output "dns_name" {  value = "${aws_lb.application-nlb.dns_name}" }
output "lb_target_group_arn" {  value = "${aws_lb_target_group.applicaion-nlb-target-group.arn}" }
output "lb_address" {  value = "${aws_lb.application-nlb.dns_name}" }
output "lb_arn" {value = "${aws_lb.application-nlb.arn}"}