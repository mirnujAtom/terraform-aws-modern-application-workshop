module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc?ref=v1.66.0"
  name = "${var.app_name}-vpc"
  azs   = "${var.avz_names}"

  cidr = "${var.vpc_cidr}"
  public_subnets = "${var.public_subnets}"
  private_subnets = "${var.private_subnets}"

  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = true
  enable_dynamodb_endpoint = true
}

