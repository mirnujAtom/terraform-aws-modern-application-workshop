output "public_subnets" { value = "${module.vpc.public_subnets}" }
output "private_subnets" { value = "${module.vpc.private_subnets}" }
output "vpc_id" { value = "${module.vpc.vpc_id}" }
output "vpc_cidr" { value = "${var.vpc_cidr}" }
output "ecs_service_role_arn" {  value = "${aws_iam_role.EcsServiceRole.arn}" }
output "ecs_task_role_arn" {  value = "${aws_iam_role.ECSTaskRole.arn}" }
output "fargate_container_security_group_arn" {  value = "${aws_security_group.fargate_sg.arn}" }
output "fargate_container_security_group_id" {  value = "${aws_security_group.fargate_sg.id}" }
output "CodeBuildRole" {  value = "${aws_iam_role.MythicalMysfitsServiceCodeBuildServiceRole.arn}" }
output "CodePipelineRole" {  value = "${aws_iam_role.MythicalMysfitsServiceCodePipelineServiceRole.arn}" }
output "dns_name" {  value = "${aws_lb.application-nlb.dns_name}" }
output "lb_target_group_arn" {  value = "${aws_lb_target_group.applicaion-nlb-target-group.arn}" }
output "lb_address" {  value = "${aws_lb.application-nlb.dns_name}" }