resource "aws_security_group" "fargate_sg" {
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
}