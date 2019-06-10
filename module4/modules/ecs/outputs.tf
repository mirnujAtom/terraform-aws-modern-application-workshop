output "ecs_cluster_id" {
  value = "${aws_ecs_cluster.app-ecs-cluster.id}"
}
output "ecs_service_id" {
  value = "${aws_ecs_service.app-ecs-service.id}"
}
output "ecr_repo_name" {
  value = "${aws_ecr_repository.app-repo.name}"
}