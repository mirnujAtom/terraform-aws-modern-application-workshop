resource "aws_ecr_repository" "app-repo" {
  name = "${var.app_name}/service"
}

resource "aws_ecs_cluster" "app-ecs-cluster" {
  name = "${var.app_name}-cluster"
}

resource "aws_cloudwatch_log_group" "app-ecs-log-group" {
  name = "${var.app_name}-logs"

  tags = {
    Environment = "${var.environment}"
    Application = "${var.app_name}"
  }
}

module "container_definitions" {
  source = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition?ref=tags/0.14.0"
  container_name = "${var.app_name}-service"
  container_image = "${var.app_image}"

  port_mappings = [
    {
      containerPort = 8080
      hostPort      = ""
      protocol      = "tcp"
    },
  ]

  log_driver = "awslogs"
  log_options = {
    awslogs-group = "${aws_cloudwatch_log_group.app-ecs-log-group.name}"
    awslogs-region = "${var.region}"
    awslogs-stream-prefix = "awslogs-${var.app_name}-service"
  }
  essential = "true"
}

resource "aws_ecs_task_definition" "app-task-definition" {
  family                = "${var.app_name}-${var.environment}-service"
  cpu = "512"
  memory = "1024"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = "${var.ecs_service_role_arn}"
  task_role_arn = "${var.ecs_task_role_arn}"
  container_definitions = "${module.container_definitions.json}"

}


resource "aws_ecs_service" "app-ecs-service" {
  name = "${var.app_name}-service"
  cluster = "${aws_ecs_cluster.app-ecs-cluster.name}"
  task_definition = "${aws_ecs_task_definition.app-task-definition.family}"
  launch_type = "FARGATE"

  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 0

  desired_count = 1

  network_configuration {
    assign_public_ip = false
    security_groups = [ "${var.fg_sg_id}" ]
    subnets = [ "${var.private_subnets}" ]
  }
  load_balancer {
    container_name = "${var.app_name}-service"
    container_port = 8080
    target_group_arn = "${var.lb_target_group_arn}"
  }
}