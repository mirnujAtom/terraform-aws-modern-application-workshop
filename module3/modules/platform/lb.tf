resource "aws_lb" "application-nlb" {
  name = "${var.app_name}-${var.environment}-nlb"
  load_balancer_type = "network"
  internal = false
  subnets = [ "${module.vpc.public_subnets}"]

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_lb_target_group" "applicaion-nlb-target-group" {
  name = "${var.app_name}-${var.environment}-targetgroup"
  port = 8080
  protocol = "TCP"
  target_type = "ip"
  vpc_id = "${module.vpc.vpc_id}"
  health_check {
    interval = 10
    path = "/"
    protocol = "HTTP"
    healthy_threshold = 3
    unhealthy_threshold = 3

  }
  depends_on = ["aws_lb.application-nlb"]
}

resource "aws_lb_listener" "application-nlb-listener" {
  load_balancer_arn = "${aws_lb.application-nlb.arn}"
  port = 80
  protocol = "TCP"
  "default_action" {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.applicaion-nlb-target-group.arn}"
  }
}