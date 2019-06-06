resource "aws_security_group" "fargate_sg" {
  vpc_id = "${module.vpc.vpc_id}"
  name = "${var.app_name}-${var.environment}-fargate-sg"
  tags {
    Name = "${var.app_name}-${var.environment}-fargate-sg"
  }

  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}